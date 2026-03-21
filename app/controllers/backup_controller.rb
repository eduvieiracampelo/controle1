class BackupController < ApplicationController
  def show
    @db_path = Rails.root.join("storage/#{Rails.env}.sqlite3")
    @db_exists = @db_path.exist?
    @db_size = @db_exists ? number_to_human_size(@db_path.size) : nil
    @db_modified = @db_exists ? l(@db_path.mtime, format: :long) : nil
  end

  def download
    db_path = Rails.root.join("storage/#{Rails.env}.sqlite3")

    unless db_path.exist?
      redirect_to backup_path, alert: "Banco de dados não encontrado."
      return
    end

    filename = "backup_#{Rails.env}_#{Date.current.iso8601}.sqlite3"

    send_file db_path, filename: filename, type: "application/x-sqlite3"
  end

  def restore
    uploaded_file = params[:file]

    unless uploaded_file
      redirect_to backup_path, alert: "Nenhum arquivo selecionado."
      return
    end

    unless valid_sqlite_file?(uploaded_file)
      redirect_to backup_path, alert: "Arquivo inválido. Selecione um arquivo .sqlite3 ou .sqlite"
      return
    end

    db_path = Rails.root.join("storage/#{Rails.env}.sqlite3")

    begin
      File.binwrite(db_path, uploaded_file.read)

      redirect_to backup_path, notice: "Backup restaurado com sucesso!"
    rescue => e
      redirect_to backup_path, alert: "Erro ao restaurar backup: #{e.message}"
    end
  end

  private

  def valid_sqlite_file?(file)
    return false unless file.content_type.in?(%w[application/x-sqlite3 application/octet-stream])

    original_filename = file.original_filename.downcase
    original_filename.ends_with?(".sqlite3") || original_filename.ends_with?(".sqlite")
  end

  def number_to_human_size(bytes)
    units = [ "B", "KB", "MB", "GB" ]
    return "0 B" if bytes == 0

    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = [ exp, units.size - 1 ].min

    "#{(bytes.to_f / 1024**exp).round(2)} #{units[exp]}"
  end
end
