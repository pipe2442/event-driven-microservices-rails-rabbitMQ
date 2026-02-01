class Order < ApplicationRecord
  before_validation :set_public_id, on: :create

  validates :public_id, presence: true, uniqueness: true
  validates :customer_public_id, presence: true
  validates :product_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :delivery_address, presence: true
  validates :status, presence: true, inclusion: { in: %w[created processing shipped delivered cancelled] }


  def to_param
    public_id
  end

  private

  def set_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
