puts "Seeding database..."

puts "Creating user..."
User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "Creating categories..."
expense_categories = [
  { name: "Alimentação", icon: "utensils", color: "#F59E0B" },
  { name: "Moradia", icon: "home", color: "#3B82F6" },
  { name: "Transporte", icon: "car", color: "#8B5CF6" },
  { name: "Saúde", icon: "heart", color: "#EF4444" },
  { name: "Lazer", icon: "gamepad", color: "#10B981" },
  { name: "Educação", icon: "book", color: "#6366F1" },
  { name: "Serviços", icon: "wrench", color: "#64748B" }
]

income_categories = [
  { name: "Salário", icon: "briefcase", color: "#22C55E" },
  { name: "Freelance", icon: "laptop", color: "#14B8A6" },
  { name: "Investimentos", icon: "trending-up", color: "#0EA5E9" },
  { name: "Outros", icon: "plus-circle", color: "#84CC16" }
]

expense_categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.category_type = :expense
    c.icon = attrs[:icon]
    c.color = attrs[:color]
  end
end

income_categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.category_type = :income
    c.icon = attrs[:icon]
    c.color = attrs[:color]
  end
end

puts "Creating accounts..."
Account.find_or_create_by!(name: "Conta Corrente") do |a|
  a.account_type = :checking
  a.balance = 5500
  a.color = "#3B82F6"
  a.icon = "bank"
end

Account.find_or_create_by!(name: "Poupança") do |a|
  a.account_type = :savings
  a.balance = 500
  a.color = "#10B981"
  a.icon = "piggy-bank"
end

Account.find_or_create_by!(name: "Carteira") do |a|
  a.account_type = :wallet
  a.balance = 100
  a.color = "#F59E0B"
  a.icon = "wallet"
end

Account.find_or_create_by!(name: "Cartão Nubank") do |a|
  a.account_type = :credit_card
  a.balance = 0
  a.credit_limit = 5000
  a.color = "#8B5CF6"
  a.icon = "credit-card"
end

puts "Creating tags..."
Tag.find_or_create_by!(name: "Importante")
Tag.find_or_create_by!(name: "Fixo")
Tag.find_or_create_by!(name: "Variável")
Tag.find_or_create_by!(name: "Urgente")
Tag.find_or_create_by!(name: "Parcelado")

puts "Creating transactions..."

today = Date.current
salario = Category.find_by(name: "Salário")
freelance = Category.find_by(name: "Freelance")
alimentacao = Category.find_by(name: "Alimentação")
moradia = Category.find_by(name: "Moradia")
transporte = Category.find_by(name: "Transporte")
saude = Category.find_by(name: "Saúde")
lazer = Category.find_by(name: "Lazer")
servicos = Category.find_by(name: "Serviços")
conta_corrente = Account.find_by(name: "Conta Corrente")
carteira = Account.find_by(name: "Carteira")
cartao = Account.find_by(name: "Cartão Nubank")

transactions = [
  { amount: 5500, description: "Salário Empresa Tech", transaction_type: :income, date: today - 5, paid: true, account: conta_corrente, category: salario },
  { amount: 1200, description: "Freelance Website", transaction_type: :income, date: today - 10, paid: true, account: conta_corrente, category: freelance },

  { amount: 1500, description: "Aluguel Apartamento", transaction_type: :expense, date: today - 4, paid: true, account: conta_corrente, category: moradia },
  { amount: 450, description: "Condomínio", transaction_type: :expense, date: today - 4, paid: true, account: conta_corrente, category: moradia },
  { amount: 350, description: "Internet Residencial", transaction_type: :expense, date: today - 3, paid: true, account: conta_corrente, category: servicos },
  { amount: 200, description: "Conta de Luz", transaction_type: :expense, date: today - 2, paid: true, account: conta_corrente, category: servicos },

  { amount: 85, description: "Supermercado Extra", transaction_type: :expense, date: today - 12, paid: true, account: cartao, category: alimentacao },
  { amount: 120, description: "Restaurante Japonês", transaction_type: :expense, date: today - 8, paid: true, account: cartao, category: alimentacao },
  { amount: 65, description: "Padaria", transaction_type: :expense, date: today - 6, paid: true, account: carteira, category: alimentacao },
  { amount: 95, description: "Hortifruti", transaction_type: :expense, date: today - 2, paid: false, account: cartao, category: alimentacao },

  { amount: 150, description: "Uber Mês", transaction_type: :expense, date: today - 15, paid: true, account: cartao, category: transporte },
  { amount: 130, description: "Posto Shell", transaction_type: :expense, date: today - 7, paid: true, account: cartao, category: transporte },
  { amount: 100, description: "Metrô", transaction_type: :expense, date: today - 1, paid: true, account: carteira, category: transporte },

  { amount: 180, description: "Farmácia Droga Raia", transaction_type: :expense, date: today - 9, paid: true, account: cartao, category: saude },
  { amount: 350, description: "Academia Smart Fit", transaction_type: :expense, date: today - 6, paid: true, account: conta_corrente, category: saude },

  { amount: 89, description: "Cinema + Pipoca", transaction_type: :expense, date: today - 11, paid: true, account: cartao, category: lazer },
  { amount: 250, description: "Streaming (Netflix, Spotify)", transaction_type: :expense, date: today - 5, paid: true, account: conta_corrente, category: lazer },
  { amount: 180, description: "Bar com Amigos", transaction_type: :expense, date: today - 1, paid: false, account: cartao, category: lazer },

  { amount: 400, description: "iPhone 15 Parcelado (3/12)", transaction_type: :expense, date: today - 20, paid: true, account: cartao, category: lazer }
]

transactions.each do |t|
  begin
    Transaction.create!(t)
    puts "  Created: #{t[:description]}"
  rescue => e
    puts "  Error creating #{t[:description]}: #{e.message}"
  end
end

puts "\nSeeding complete!"
puts "#{Account.count} contas"
puts "#{Category.count} categorias"
puts "#{Transaction.count} transações"
puts "#{Tag.count} tags"
