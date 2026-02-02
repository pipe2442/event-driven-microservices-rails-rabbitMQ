require "rails_helper"

RSpec.describe Orders::Create do
  it "creates order and publishes event" do
    publisher = instance_double(Events::RabbitmqPublisher)
    allow(publisher).to receive(:publish_order_created)

    result = described_class.new(
      attributes_for(:order),
      publisher: publisher
    ).call

    expect(result.order).to be_present
    expect(publisher).to have_received(:publish_order_created).with(result.order)
  end

  it "returns errors and does not publish when invalid" do
    publisher = instance_double(Events::RabbitmqPublisher)
    allow(publisher).to receive(:publish_order_created)

    result = described_class.new(
      attributes_for(
        :order,
        customer_public_id: nil,
        product_name: "",
        quantity: 0,
        price: -1,
        delivery_address: ""
      ),
      publisher: publisher
    ).call

    expect(result.order).to be_nil
    expect(result.errors).to be_present
    expect(publisher).not_to have_received(:publish_order_created)
  end
end
