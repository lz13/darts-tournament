class PlayersController < ApplicationController
  include AdminTokenVerifiable

  before_action :set_tournament_and_verify_admin
  before_action :verify_tournament_is_draft, only: %i[create destroy]

  def create
    @player = @tournament.players.build(player_params)

    respond_to do |format|
      if @player.save
        format.turbo_stream
        format.html { redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token), notice: "Player added successfully!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_player_form",
            partial: "players/form",
            locals: { tournament: @tournament, player: @player }
          )
        end
        format.html { redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token), alert: "Failed to add player. Please check the form and try again." }
      end
    end
  end

  def destroy
    @player = @tournament.players.find(params[:id])
    @player.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token), notice: "Player removed successfully!" }
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :seed_number)
  end

  def set_tournament_and_verify_admin
    @tournament = Tournament.find_by!(share_token: params[:share_token])
    raise ActiveRecord::RecordNotFound unless valid_admin_token?(params[:admin_token])
  end

  def verify_tournament_is_draft
    return if @tournament.draft?

    if request.format.html?
      redirect_to admin_tournament_path(@tournament.share_token, @tournament.admin_token),
                  alert: "Cannot modify players after tournament has started."
    else
      head :unprocessable_entity
    end
  end
end
