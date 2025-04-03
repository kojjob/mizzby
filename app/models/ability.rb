# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here.
    user ||= User.new # guest user (not logged in)

    if user.super_admin? || user.admin?
      # Super admin and admin can do everything
      can :manage, :all
    elsif user.seller?
      # Seller-specific permissions
      # Can manage their own products
      can :manage, Product, seller: { user_id: user.id }
      # Can manage orders for their products
      can :manage, Order, product: { seller: { user_id: user.id } }
      # Can manage their own seller profile
      can :manage, Seller, user_id: user.id
      # Can answer questions on their products
      can :answer, ProductQuestion, product: { seller: { user_id: user.id } }
      # Can view their own data
      can :read, Product, seller: { user_id: user.id }
      can :read, Order, product: { seller: { user_id: user.id } }
      # Can read categories and browse products
      can :read, Category
      can :read, Product, published: true
    else
      # Regular user permissions
      # Can manage their own cart
      can :manage, Cart, user_id: user.id
      can :manage, CartItem, cart: { user_id: user.id }
      # Can manage their own orders
      can :manage, Order, user_id: user.id
      # Can manage their own reviews
      can :manage, Review, user_id: user.id
      # Can ask questions on products
      can :create, ProductQuestion
      can :manage, ProductQuestion, user_id: user.id
      # Can manage their own wishlist
      can :manage, WishlistItem, user_id: user.id
      # Can read published products and categories
      can :read, Product, published: true
      can :read, Category, visible: true
      # Can register as a seller
      can :create, Seller
    end

    # Everyone (including guests) can:
    can :read, Product, published: true
    can :read, Category, visible: true
    can :read, Review, published: true
  end
end
