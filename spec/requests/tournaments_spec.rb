require 'rails_helper'

RSpec.describe "Tournaments", type: :request do
  describe "GET /tournaments" do
    it "renders the tournaments index" do
      get tournaments_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tournaments")
    end

    context "with existing tournaments" do
      let!(:tournament) { create(:tournament, name: "Test Tournament") }
      let!(:old_tournament) { create(:tournament, name: "Old Tournament", created_at: 1.day.ago) }

      it "displays all tournaments" do
        get tournaments_path
        expect(response.body).to include("Test Tournament")
        expect(response.body).to include("Old Tournament")
      end

      it "shows tournaments sorted by newest first" do
        get tournaments_path
        body = response.body
        expect(body.index("Test Tournament")).to be < body.index("Old Tournament")
      end

      it "shows tournament status" do
        get tournaments_path
        expect(response.body).to include("Draft")
      end
    end

    context "with no tournaments" do
      it "shows empty state with CTA" do
        get tournaments_path
        expect(response.body).to include("No tournaments yet")
        expect(response.body).to include("Create your first tournament")
      end
    end
  end

  describe "GET /tournaments/new" do
    it "renders the new tournament form" do
      get new_tournament_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create New Tournament")
    end
  end

  describe "POST /tournaments" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          tournament: {
            name: "Test Tournament",
            legs_to_win: 3,
            seeding_method: "ordered"
          }
        }
      end

      it "creates a new tournament" do
        expect {
          post tournaments_path, params: valid_params
        }.to change(Tournament, :count).by(1)
      end

      it "redirects to the public tournament page" do
        post tournaments_path, params: valid_params
        tournament = Tournament.last
        expect(response).to redirect_to(public_tournament_path(tournament&.share_token))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          tournament: {
            name: "",
            legs_to_win: 3,
            seeding_method: "ordered"
          }
        }
      end

      it "does not create a tournament" do
        expect {
          post tournaments_path, params: invalid_params
        }.not_to change(Tournament, :count)
      end

      it "renders the new form with errors" do
        post tournaments_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /t/:share_token" do
    let(:tournament) { create(:tournament) }

    it "shows the public tournament view" do
      get public_tournament_path(tournament.share_token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(tournament.name)
    end

    it "returns 404 for invalid share token" do
      get public_tournament_path("invalid-token")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /t/:share_token/admin/:admin_token" do
    let(:tournament) { create(:tournament) }

    it "shows the admin view with valid tokens" do
      get admin_tournament_path(tournament.share_token, tournament.admin_token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(tournament.name)
      expect(response.body).to include("Share Link")
    end

    it "returns 404 for invalid admin token" do
      get admin_tournament_path(tournament.share_token, "wrong-token")
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for invalid share token" do
      get admin_tournament_path("wrong-token", tournament.admin_token)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /t/:share_token/admin/:admin_token/start" do
    let(:tournament) { create(:tournament) }

    context "with enough players" do
      before do
        create_list(:player, 4, tournament: tournament)
      end

      it "starts the tournament" do
        post start_tournament_path(tournament.share_token, tournament.admin_token)
        expect(tournament.reload.status).to eq("in_progress")
        expect(response).to redirect_to(admin_tournament_path(tournament.share_token, tournament.admin_token))
      end
    end

    context "with less than 2 players" do
      it "does not start the tournament" do
        post start_tournament_path(tournament.share_token, tournament.admin_token)
        expect(tournament.reload.status).to eq("draft")
        expect(response).to redirect_to(admin_tournament_path(tournament.share_token, tournament.admin_token))
      end
    end

    it "returns 404 for invalid admin token" do
      post start_tournament_path(tournament.share_token, "wrong-token")
      expect(response).to have_http_status(:not_found)
    end
  end
end
