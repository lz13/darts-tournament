class TournamentsController < ApplicationController
  include AdminTokenVerifiable

  before_action :set_tournament_by_share_token, only: %i[show]
  before_action :set_tournament_by_share_token_and_verify_admin, only: %i[admin start]

  def index
    @tournaments = Tournament.order(created_at: :desc)
  end

  def new
    @tournament = Tournament.new
  end

  def show
    # Placeholder
  end

  def create
    @tournament = Tournament.new(tournament_params)

    if @tournament.save
      redirect_to public_tournament_path(@tournament.share_token), notice: "Tournament created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Placeholder
  end

  def destroy
    # Placeholder
  end

  def edit
    # Placeholder
  end

  def admin
    # Placeholder
  end

  def start
    if @tournament.start!
      redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token), notice: "Tournament started! Bracket will be generated in the next phase."
    else
      redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token), alert: "Failed to start tournament. Please ensure there are enough players and try again."
    end
  end

  private

  def tournament_params
    params.require(:tournament).permit(:name, :legs_to_win, :seeding_method)
  end

  def set_tournament_by_share_token
    @tournament = Tournament.find_by!(share_token: params[:share_token])
  end

  def set_tournament_by_share_token_and_verify_admin
    @tournament = Tournament.find_by!(share_token: params[:share_token])
    raise ActiveRecord::RecordNotFound unless valid_admin_token?(params[:admin_token])
  end
end
