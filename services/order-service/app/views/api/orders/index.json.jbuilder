json.array! @orders do |order|
  json.id order.public_id
  json.customer_public_id order.customer_public_id
  json.product_name order.product_name
  json.quantity order.quantity
  json.price order.price
  json.delivery_address order.delivery_address
  json.created_at order.created_at
  json.updated_at order.updated_at
end
