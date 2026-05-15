class Player < ApplicationRecord
  belongs_to :tournament, counter_cache: true

  validates :name, presence: true
  validates :seed_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
