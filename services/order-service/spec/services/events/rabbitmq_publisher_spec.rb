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

    expect(exchange).to have_received(:publish)
  end
end
