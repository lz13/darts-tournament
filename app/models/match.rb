class Match < ApplicationRecord
  BRACKET_TYPES = %w[unassigned winners losers grand_final].freeze
  STATUSES = %w[pending ready in_progress completed].freeze

  belongs_to :tournament
  belongs_to :player_one, class_name: "Player", optional: true
  belongs_to :player_two, class_name: "Player", optional: true
  belongs_to :winner, class_name: "Player", optional: true
  belongs_to :winner_next_match, class_name: "Match", optional: true
  belongs_to :loser_next_match, class_name: "Match", optional: true

  validates :bracket_type, inclusion: { in: BRACKET_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :round_number, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  scope :winners_bracket, -> { where(bracket_type: "winners") }
  scope :losers_bracket, -> { where(bracket_type: "losers") }
  scope :grand_final, -> { where(bracket_type: "grand_final") }
  scope :completed, -> { where(status: "completed") }

  def ready?
    status == "ready"
  end

  def in_progress?
    status == "in_progress"
  end

  def completed?
    status == "completed"
  end

  def bye?
    player_one.nil? || player_two.nil?
  end

  def players_assigned?
    player_one.present? && player_two.present?
  end
end
