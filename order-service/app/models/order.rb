class Order < ApplicationRecord
  validates :status, presence: true, inclusion: { in: %w[created processing shipped delivered cancelled] }
end
