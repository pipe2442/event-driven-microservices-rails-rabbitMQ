class Customer < ApplicationRecord
  before_validation :set_public_id, on: :create

  validates :public_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :address, presence: true
  validates :orders_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def to_param
    public_id
  end

  private

  def set_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
