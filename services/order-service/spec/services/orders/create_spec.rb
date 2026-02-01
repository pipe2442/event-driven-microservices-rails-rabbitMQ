require "rails_helper"

RSpec.describe Orders::Create do
  it "creates order and publishes event" do
    publisher = instance_double(Events::RabbitmqPublisher)
    allow(publisher).to receive(:publish_order_created)

    result = described_class.new(
      {
        customer_public_id: SecureRandom.uuid,
        product_name: "Laptop",
        quantity: 1,
        price: 1200,
        delivery_address: "Calle 1"
      },
      publisher: publisher
    ).call

    expect(result.order).to be_present
    expect(publisher).to have_received(:publish_order_created)
  end
end
