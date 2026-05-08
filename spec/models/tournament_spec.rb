require 'rails_helper'

RSpec.describe Tournament, type: :model do
  describe 'associations' do
    it { should have_many(:players).dependent(:destroy) }
    # it { should have_many(:matches).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'sets default values on create' do
      tournament = Tournament.new(name: 'Test Tournament')
      tournament.valid?
      expect(tournament.status).to eq('draft')
      expect(tournament.format).to eq('double_elimination')
      expect(tournament.legs_to_win).to eq(3)
      expect(tournament.seeding_method).to eq('ordered')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_inclusion_of(:status).in_array(Tournament::STATUSES)}
    it { should validate_inclusion_of(:format).in_array(Tournament::FORMATS)}
    it { should validate_inclusion_of(:seeding_method).in_array(Tournament::SEEDING_METHODS)}
    it { should validate_numericality_of(:legs_to_win).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:share_token) }
    it { should validate_presence_of(:admin_token) }
  end

  describe 'uniqueness validations' do
    subject { create(:tournament) }
    it { should validate_uniqueness_of(:share_token) }
    it { should validate_uniqueness_of(:admin_token) }
  end

  describe 'scopes' do
    let!(:draft_tournament) { create(:tournament, status: 'draft') }
    let!(:active_tournament) { create(:tournament, status: 'in_progress') }
    let!(:completed_tournament) { create(:tournament, status: 'completed') }

    it '.draft returns only draft tournaments' do
      expect(Tournament.draft).to include(draft_tournament)
      expect(Tournament.draft).not_to include(active_tournament, completed_tournament)
    end
  end

  describe 'token generation' do
    it 'generates share_token automatically' do
      tournament = create(:tournament)
      expect(tournament.share_token).to be_present
      expect(tournament.share_token.length).to eq(24) # Default length for has_secure_token
    end

    it 'generates admin_token automatically' do
      tournament = create(:tournament)
      expect(tournament.admin_token).to be_present
      expect(tournament.admin_token.length).to eq(24)
    end
  end

  describe '#start!' do
    context 'when tournament is in draft status with enough players' do
      let(:tournament) { create(:tournament) }

      before do
        create_list(:player, 4, tournament: tournament, seed_number: nil)
      end

      it 'transitions to in_progress' do
        expect(tournament.start!).to be true
        expect(tournament.reload.status).to eq('in_progress')
      end
    end

    context 'when tournament has less than 2 players' do
      let(:tournament) { create(:tournament) }

      it 'returns false' do
        expect(tournament.start!).to be false
      end
    end
  end
end
