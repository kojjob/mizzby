class ProductQuestion < ApplicationRecord
  belongs_to :product
  belongs_to :user

  # Validations
  validates :question, presence: true, length: { minimum: 10, maximum: 500 }
  validates :asked_by, presence: true

  # Scopes
  scope :answered, -> { where.not(answer: nil) }
  scope :unanswered, -> { where(answer: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :set_answered_at, if: -> { answer.present? && answer_changed? }

  private

  def set_answered_at
    self.answered_at = Time.current
  end
end
