require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'validations' do
    # it { should validate_presence_of(:bracket_type) }
    it { should validate_inclusion_of(:bracket_type).in_array(Match::BRACKET_TYPES) }
    it { should validate_inclusion_of(:status).in_array(Match::STATUSES) }
    it { should validate_numericality_of(:round_number).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:tournament) }
    it { should belong_to(:player_one).class_name('Player').optional }
    it { should belong_to(:player_two).class_name('Player').optional }
    it { should belong_to(:winner).class_name('Player').optional }
    it { should belong_to(:winner_next_match).class_name('Match').optional }
    it { should belong_to(:loser_next_match).class_name('Match').optional }
  end

  describe 'scopes' do
    let!(:winners_match) { create(:match, bracket_type: 'winners') }
    let!(:losers_match) { create(:match, bracket_type: 'losers') }
    let!(:grand_final) { create(:match, bracket_type: 'grand_final') }

    it '.winners_bracket returns only winners bracket matches' do
      expect(Match.winners_bracket).to include(winners_match)
      expect(Match.winners_bracket).not_to include(losers_match, grand_final)
    end
  end

  describe '#ready?' do
    it 'returns true when status is ready' do
      match = create(:match, status: 'ready')
      expect(match.ready?).to be true
    end

    it 'returns false when status is not ready' do
      match = create(:match, status: 'completed')
      expect(match.ready?).to be false
    end
  end

  describe '#in_progress?' do
    it 'returns true when status is in_progress' do
      match = create(:match, status: 'in_progress')
      expect(match.in_progress?).to be true
    end

    it 'returns false when status is not in_progress' do
      match = create(:match, status: 'completed')
      expect(match.in_progress?).to be false
    end
  end

  describe 'completed?' do
    it 'returns true when status is completed' do
      match = create(:match, status: 'completed')
      expect(match.completed?).to be true
    end

    it 'returns false when status is not completed' do
      match = create(:match, status: 'in_progress')
      expect(match.completed?).to be false
    end
  end

  describe '#bye?' do
    it 'returns true when a player is missing' do
      match = create(:match, :bye)
      expect(match.bye?).to be true
    end
    it 'returns false when both players are present' do
      match = create(:match, :ready)
      expect(match.bye?).to be false
    end
  end

  describe '#players_assigned?' do
    it 'returns true when both players are assigned' do
      match = create(:match, :ready)
      expect(match.players_assigned?).to be true
    end

    it 'returns false when one player is missing' do
      match = create(:match, :bye)
      expect(match.players_assigned?).to be false
    end
  end
end
