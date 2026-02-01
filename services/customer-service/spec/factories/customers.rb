FactoryBot.define do
  factory :customer do
    public_id { SecureRandom.uuid }
    name { "Juan Perez" }
    address { "Cra 7 #12-34" }
    orders_count { 0 }
  end
end
