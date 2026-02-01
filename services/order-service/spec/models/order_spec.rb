require "rails_helper"

RSpec.describe Order, type: :model do
  it "is valid with required attributes" do
    order = build(:order)
    expect(order).to be_valid
  end

  it "is invalid without customer_public_id" do
    order = build(:order, customer_public_id: nil)
    expect(order).not_to be_valid
  end

  it "is invalid without product_name" do
    order = build(:order, product_name: nil)
    expect(order).not_to be_valid
  end

  it "is invalid with non-positive quantity" do
    order = build(:order, quantity: 0)
    expect(order).not_to be_valid
  end

  it "is invalid with negative price" do
    order = build(:order, price: -1)
    expect(order).not_to be_valid
  end

  it "is invalid without delivery_address" do
    order = build(:order, delivery_address: nil)
    expect(order).not_to be_valid
  end

  it "is invalid with unsupported status" do
    order = build(:order, status: "unknown")
    expect(order).not_to be_valid
  end
end
