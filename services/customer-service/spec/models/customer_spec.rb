require "rails_helper"

RSpec.describe Customer, type: :model do
  it "is valid with required attributes" do
    customer = build(:customer)
    expect(customer).to be_valid
  end

  it "is invalid without name" do
    customer = build(:customer, name: nil)
    expect(customer).not_to be_valid
  end

  it "is invalid without address" do
    customer = build(:customer, address: nil)
    expect(customer).not_to be_valid
  end

  it "is invalid with negative orders_count" do
    customer = build(:customer, orders_count: -1)
    expect(customer).not_to be_valid
  end
end
