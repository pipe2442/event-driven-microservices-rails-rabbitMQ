customers = [
  {
    public_id: "11111111-1111-1111-1111-111111111111",
    name: "Juan Perez",
    address: "Cra 7 #12-34, Bogotá"
  },
  {
    public_id: "22222222-2222-2222-2222-222222222222",
    name: "Maria Gomez",
    address: "Calle 123 #45-67, Medellín"
  },
  {
    public_id: "33333333-3333-3333-3333-333333333333",
    name: "Carlos Ruiz",
    address: "Av 10 #20-30, Cali"
  }
]

customers.each do |attrs|
  Customer.find_or_create_by!(public_id: attrs[:public_id]) do |c|
    c.name = attrs[:name]
    c.address = attrs[:address]
    c.orders_count = 0
  end
end

puts "Seeded #{Customer.count} customers"
puts "Public IDs:"
Customer.order(:id).pluck(:name, :public_id).each do |name, pid|
  puts "- #{name}: #{pid}"
end
