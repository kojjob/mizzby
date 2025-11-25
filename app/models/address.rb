class Address < ApplicationRecord
  belongs_to :user

  validates :street_address, :city, :postal_code, :country, presence: true

  before_save :ensure_single_default

  scope :default_first, -> { order(default: :desc, created_at: :desc) }

  private

  def ensure_single_default
    if default? && default_changed?
      user.addresses.where.not(id: id).update_all(default: false)
    end
  end
end
