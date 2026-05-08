require 'rails_helper'

RSpec.describe Player, type: :model do
  it { should belong_to(:tournament) }
  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:seed_number).only_integer.is_greater_than(0).allow_nil }
end
