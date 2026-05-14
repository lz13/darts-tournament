require 'rails_helper'

RSpec.describe PlayersHelper, type: :helper do
  it 'does not define any custom helper methods yet' do
    expect(described_class.instance_methods(false)).to be_empty
  end
end
