class Order < ApplicationRecord
  validates :status, presence: true, inclusion: { in: %w[created processing shipped delivered cancelled] }


  def to_param
    public_id
  end
end
