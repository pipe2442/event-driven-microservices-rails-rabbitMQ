require "rails_helper"

RSpec.describe Events::RabbitmqPublisher do
  it "publishes order.created event" do
    conn = instance_double(Bunny::Session)
    ch = instance_double(Bunny::Channel)
    exchange = instance_double(Bunny::Exchange)

    allow(Bunny).to receive(:new).and_return(conn)
    allow(conn).to receive(:start)
    allow(conn).to receive(:create_channel).and_return(ch)
    allow(ch).to receive(:topic).and_return(exchange)
    allow(exchange).to receive(:publish)
    allow(conn).to receive(:close)

    order = build(:order)
    described_class.new.publish_order_created(order)

    expect(exchange).to have_received(:publish) do |payload, options|
      data = JSON.parse(payload)

      expect(data["event"]).to eq("order.created")
      expect(data.dig("data", "order_public_id")).to eq(order.public_id)
      expect(data.dig("data", "customer_public_id")).to eq(order.customer_public_id)
      expect(data["event_id"]).to be_present

      expect(options).to include(
        routing_key: "order.created",
        persistent: true,
        content_type: "application/json",
        message_id: data["event_id"]
      )
    end
  end
end
