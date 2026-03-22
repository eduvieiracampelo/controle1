#!/bin/bash

# ================================================
# Script de Backup - Sistema de Controle Financeiro
# ================================================

set -e

# Configurações
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="$PROJECT_DIR/storage/development.sqlite3"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILENAME="backup_${TIMESTAMP}.sqlite3"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILENAME"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funções
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se o diretório de backups existe
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log_info "Criando diretório de backups: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Verificar se o banco de dados existe
check_database() {
    if [ ! -f "$DB_PATH" ]; then
        log_error "Banco de dados não encontrado: $DB_PATH"
        exit 1
    fi
    log_info "Banco de dados encontrado: $DB_PATH"
}

# Criar o backup
create_backup() {
    log_info "Criando backup..."

    cp "$DB_PATH" "$BACKUP_PATH"

    if [ $? -eq 0 ]; then
        log_info "Backup criado com sucesso!"
        log_info "Arquivo: $BACKUP_PATH"
        
        SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
        log_info "Tamanho: $SIZE"
    else
        log_error "Falha ao criar backup"
        exit 1
    fi
}

# Criar backup compactado (opcional)
create_compressed_backup() {
    local compressed_path="$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"
    
    log_info "Criando backup compactado..."
    
    tar -czf "$compressed_path" -C "$PROJECT_DIR" "storage/development.sqlite3" db/seeds.rb 2>/dev/null || \
    tar -czf "$compressed_path" -C "$PROJECT_DIR" "storage/development.sqlite3" 2>/dev/null || true

    if [ -f "$compressed_path" ]; then
        log_info "Backup compactado criado: $compressed_path"
        SIZE=$(du -h "$compressed_path" | cut -f1)
        log_info "Tamanho compactado: $SIZE"
    fi
}

# Listar backups existentes
list_backups() {
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        log_info "Backups existentes:"
        echo ""
        ls -1 "$BACKUP_DIR" | while read file; do
            if [ -f "$BACKUP_DIR/$file" ]; then
                SIZE=$(du -h "$BACKUP_DIR/$file" | cut -f1)
                echo "  $file ($SIZE)"
            fi
        done
        echo ""
    else
        log_info "Nenhum backup encontrado"
    fi
}

# Restaurar backup (requer arquivo como argumento)
restore_backup() {
    local restore_file="$1"
    
    if [ -z "$restore_file" ]; then
        log_error "Uso: $0 restore <arquivo_backup>"
        exit 1
    fi
    
    if [ ! -f "$restore_file" ]; then
        log_error "Arquivo de backup não encontrado: $restore_file"
        exit 1
    fi
    
    log_warn "Restaurando backup..."
    log_warn "Arquivo: $restore_file"
    
    # Fazer backup do banco atual antes de restaurar
    local current_backup="$BACKUP_DIR/pre_restore_$(date +%Y%m%d_%H%M%S).sqlite3"
    if [ -f "$DB_PATH" ]; then
        cp "$DB_PATH" "$current_backup"
        log_info "Backup do banco atual salvo em: $current_backup"
    fi
    
    cp "$restore_file" "$DB_PATH"
    
    if [ $? -eq 0 ]; then
        log_info "Backup restaurado com sucesso!"
    else
        log_error "Falha ao restaurar backup"
        exit 1
    fi
}

# Mostrar ajuda
show_help() {
    echo "=========================================="
    echo "  Script de Backup - Controle Financeiro"
    echo "=========================================="
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  backup              Criar backup do banco de dados"
    echo "  backup-compressed   Criar backup compactado"
    echo "  list                Listar backups existentes"
    echo "  restore <arquivo>   Restaurar um backup"
    echo "  help                Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 backup"
    echo "  $0 backup-compressed"
    echo "  $0 list"
    echo "  $0 restore backups/backup_20240101_120000.sqlite3"
    echo ""
}

# Menu principal
case "${1:-help}" in
    backup)
        create_backup_dir
        check_database
        create_backup
        ;;
    backup-compressed)
        create_backup_dir
        check_database
        create_backup
        create_compressed_backup
        ;;
    list)
        list_backups
        ;;
    restore)
        create_backup_dir
        restore_backup "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Comando desconhecido: $1"
        show_help
        exit 1
        ;;
esac
