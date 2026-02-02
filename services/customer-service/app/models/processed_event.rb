class ProcessedEvent < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :event_name, presence: true
end
