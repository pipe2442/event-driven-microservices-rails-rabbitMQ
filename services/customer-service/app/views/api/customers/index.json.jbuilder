json.array! @customers do |customer|
  json.id customer.public_id
  json.name customer.name
  json.address customer.address
  json.orders_count customer.orders_count
end
