class Player < ApplicationRecord
  belongs_to :tournament

  validates :name, presence: true
  validates :seed_number, presence: true, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
