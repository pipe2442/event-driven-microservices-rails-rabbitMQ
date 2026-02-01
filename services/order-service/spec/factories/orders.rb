FactoryBot.define do
  factory :order do
    public_id { SecureRandom.uuid }
    customer_public_id { SecureRandom.uuid }
    product_name { "Laptop" }
    quantity { 1 }
    price { 1200.0 }
    delivery_address { "Calle 123" }
    status { "created" }
  end
end
