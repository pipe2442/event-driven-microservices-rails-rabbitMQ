require "rails_helper"

RSpec.describe Events::OrderCreatedConsumer do
  it "increments orders_count" do
    customer = create(:customer, orders_count: 0)
    payload = { data: { customer_public_id: customer.public_id } }.to_json

    consumer = described_class.new
    consumer.send(:handle_message, payload)

    expect(customer.reload.orders_count).to eq(1)
  end
end
