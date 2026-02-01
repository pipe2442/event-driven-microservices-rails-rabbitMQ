# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

customers = [
  { name: "Juan Perez", address: "Cra 7 #12-34, Bogotá" },
  { name: "Maria Gomez", address: "Calle 123 #45-67, Medellín" },
  { name: "Carlos Ruiz", address: "Av 10 #20-30, Cali" }
]

customers.each do |attrs|
  Customer.find_or_create_by!(name: attrs[:name]) do |c|
    c.address = attrs[:address]
    c.orders_count = 0
  end
end

puts "Seeded #{Customer.count} customers"
puts "Public IDs:"
Customer.order(:id).pluck(:name, :public_id).each do |name, pid|
  puts "- #{name}: #{pid}"
end
