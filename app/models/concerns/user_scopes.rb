module UserScopes
  extend ActiveSupport::Concern

  included do
    # Add scopes here as needed
    # scope :active, -> { where(status: :active) }
    # scope :sellers, -> { joins(:seller) }
    # scope :customers, -> { left_outer_joins(:seller).where(sellers: { id: nil }) }
  end
end
