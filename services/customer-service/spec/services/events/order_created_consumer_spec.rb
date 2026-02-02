require "rails_helper"

RSpec.describe Events::OrderCreatedConsumer do
  it "increments orders_count and records event" do
    customer = create(:customer, orders_count: 0)
    payload = {
      event_id: SecureRandom.uuid,
      event: "order.created",
      occurred_at: Time.now.utc.iso8601,
      data: { customer_public_id: customer.public_id }
    }.to_json

    consumer = described_class.new
    consumer.send(:handle_message, payload)

    expect(customer.reload.orders_count).to eq(1)
    expect(ProcessedEvent.count).to eq(1)
  end

  it "is idempotent for duplicate event_id" do
    customer = create(:customer, orders_count: 0)
    event_id = SecureRandom.uuid
    payload = {
      event_id: event_id,
      event: "order.created",
      occurred_at: Time.now.utc.iso8601,
      data: { customer_public_id: customer.public_id }
    }.to_json

    consumer = described_class.new
    5.times { consumer.send(:handle_message, payload) }

    expect(customer.reload.orders_count).to eq(1)
    expect(ProcessedEvent.where(event_id: event_id).count).to eq(1)
  end

  it "does nothing when event_id is missing" do
    customer = create(:customer, orders_count: 0)
    payload = {
      event: "order.created",
      occurred_at: Time.now.utc.iso8601,
      data: { customer_public_id: customer.public_id }
    }.to_json

    consumer = described_class.new
    consumer.send(:handle_message, payload)

    expect(customer.reload.orders_count).to eq(0)
    expect(ProcessedEvent.count).to eq(0)
  end

  it "does nothing when customer does not exist" do
    payload = {
      event_id: SecureRandom.uuid,
      event: "order.created",
      occurred_at: Time.now.utc.iso8601,
      data: { customer_public_id: "missing" }
    }.to_json

    consumer = described_class.new
    consumer.send(:handle_message, payload)

    expect(ProcessedEvent.count).to eq(0)
  end
end
