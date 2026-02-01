class Customer < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true

  def to_param
    public_id
  end
end
