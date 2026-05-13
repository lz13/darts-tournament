class Tournament < ApplicationRecord
  # Status enum with AASM-like behavior
  STATUSES = %w[draft in_progress completed].freeze
  FORMATS = %w[double_elimination].freeze
  SEEDING_METHODS = %w[ordered random manual].freeze

  # Callbacks
  before_validation :set_defaults, on: :create

  # Token generation
  has_secure_token :share_token
  has_secure_token :admin_token

  # Associations
  has_many :matches, dependent: :destroy
  has_many :players, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :status, inclusion: { in: STATUSES }
  validates :format, inclusion: { in: FORMATS }
  validates :seeding_method, inclusion: { in: SEEDING_METHODS }
  validates :legs_to_win, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :share_token, uniqueness: true
  validates :admin_token, uniqueness: true

  # Scopes
  scope :draft, -> { where(status: "draft") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }

  def draft?
    status == "draft"
  end

  def in_progress?
    status == "in_progress"
  end

  def completed?
    status == "completed"
  end

  # State transitions
  def start!
    return false unless draft?
    return false if players.count < 2

    transaction do
      apply_seeding!
      generate_bracket!
      update!(status: "in_progress")
    end
  end

  def complete!
    return false unless in_progress?

    update!(status: "completed")
  end

  private

  def set_defaults
    self.status ||= "draft"
    self.format ||= "double_elimination"
    self.legs_to_win ||= 3
    self.seeding_method ||= "ordered"
  end

  def apply_seeding!
    case seeding_method
    when "random"
      players.shuffle.each_with_index do |player, index|
        player.update!(seed_number: index + 1)
      end
    when "ordered"
      # Seeds already set by position (1, 2, 3...)
      players.order(:created_at).each_with_index do |player, index|
        player.update!(seed_number: index + 1) unless player.seed_number.present?
      end
    when "manual"
      # Auto-assign seeds if not manually set (placeholder until manual UI added)
      if players.any? { |p| p.seed_number.blank? }
        players.order(:created_at).each_with_index do |player, index|
          player.update!(seed_number: index + 1) if player.seed_number.blank?
        end
      end
    end
  end

  def generate_bracket!
    # This will be implemented in Phase 4 (BracketGenerator service)
    # For now just placeholder
    true
  end
end
