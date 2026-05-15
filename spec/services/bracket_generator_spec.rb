require 'rails_helper'

RSpec.describe BracketGenerator, type: :service do
  let(:tournament) { create(:tournament) }
  let(:generator) { described_class.new(tournament) }

  describe '#generate' do
    context 'with 2 players' do
      before do
        create_list(:player, 2, tournament: tournament, seed_number: nil)
        tournament.apply_seeding!
      end

      it 'creates matches' do
        expect { generator.generate! }.to change(Match, :count).by(3) # WB: 1, LB: 0, GF: 2
      end
    end

    context 'with 4 players' do
      before do
        create_list(:player, 4, tournament: tournament, seed_number: nil)
        tournament.apply_seeding!
      end

      it 'creates winner bracket matches' do
        generator.generate!
        expect(tournament.matches.winners_bracket.count).to eq(3) # R1: 2, R2: 1
      end

      it 'creates loser bracket matches' do
        generator.generate!
        expect(tournament.matches.losers_bracket.count).to be > 0
      end

      it 'creates grand final matches' do
        generator.generate!
        expect(tournament.matches.grand_final.count).to eq(2) # GF1 + GF2
      end

      it 'links matches together' do
        generator.generate!
        wb_r1 = tournament.matches.winners_bracket.where(round_number: 1).first

        expect(wb_r1&.winner_next_match).to be_present
      end
    end

    context 'with 8 players' do
      before do
        create_list(:player, 8, tournament: tournament, seed_number: nil)
        tournament.apply_seeding!
      end

      it 'creates correct number of matches' do
        generator.generate!
        expect(tournament.matches.count).to be > 10
      end

      it 'assigns players to first round' do
        generator.generate!
        wb_r1 = tournament.matches.winners_bracket.where(round_number: 1)
        expect(wb_r1.all? { |m| m.player_one.present? || m.player_two.present? }).to be true
      end
    end

    context 'with byes (5 players in 8 bracket)' do
      before do
        create_list(:player, 5, tournament: tournament, seed_number: nil)
        tournament.apply_seeding!
      end

      it 'handles byes correctly' do
        generator.generate!
        bye_matches = tournament.matches.winners_bracket.where(round_number: 1).select { |m| m.bye? }
        expect(bye_matches.all? { |m| m.status == 'completed' }).to be true
      end
    end
  end
end
