require 'rails_helper'

RSpec.describe "Players", type: :request do
  let(:tournament) { create(:tournament) }

  describe "POST /t/:share_token/admin/:admin_token/players" do
    context "with valid parameters" do
      let(:valid_params) do
        { player: { name: "John Doe" } }
      end

      it "creates a new player" do
        expect {
          post tournament_players_path(tournament.share_token, tournament.admin_token),
               params: valid_params,
               as: :turbo_stream
        }.to change(tournament.players, :count).by(1)
      end

      it "returns turbo stream response" do
        post tournament_players_path(tournament.share_token, tournament.admin_token),
             params: valid_params,
             as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { player: { name: "" } }
      end

      it "does not create a player" do
        expect {
          post tournament_players_path(tournament.share_token, tournament.admin_token),
               params: invalid_params,
               as: :turbo_stream
        }.not_to change(tournament.players, :count)
      end
    end

    it "returns 404 for invalid admin token" do
      post tournament_players_path(tournament.share_token, "wrong-token"), params: { player: { name: "John" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /t/:share_token/admin/:admin_token/players/:id" do
    let!(:player) { create(:player, tournament: tournament) }

    it "removes the player" do
      expect {
        delete tournament_player_path(tournament.share_token, tournament.admin_token, player),
               as: :turbo_stream
      }.to change(tournament.players, :count).by(-1)
    end

    it "returns turbo stream response" do
      delete tournament_player_path(tournament.share_token, tournament.admin_token, player),
             as: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "returns 404 for invalid admin token" do
      delete tournament_player_path(tournament.share_token, "wrong-token", player)
      expect(response).to have_http_status(:not_found)
    end
  end
end
