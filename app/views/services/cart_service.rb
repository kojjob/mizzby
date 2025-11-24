class CartService
  def initialize(user)
    @user = user
    @cart = user.cart || user.create_cart
  end

  def add_product(product, quantity = 1)
    return false unless product.available_for_purchase?

    cart_item = @cart.cart_items.find_by(product: product)

    if cart_item
      new_quantity = cart_item.quantity + quantity
      cart_item.update(quantity: new_quantity)
    else
      cart_item = @cart.cart_items.create(
        product: product,
        quantity: quantity,
        price: product.current_price
      )
    end

    @cart.update_total_price!
    cart_item
  end

  def remove_product(product)
    cart_item = @cart.cart_items.find_by(product: product)
    return false unless cart_item

    cart_item.destroy
    @cart.update_total_price!
    true
  end

  def update_quantity(product, quantity)
    cart_item = @cart.cart_items.find_by(product: product)
    return false unless cart_item

    cart_item.update(quantity: quantity)
    @cart.update_total_price!
    cart_item
  end

  def empty_cart
    @cart.cart_items.destroy_all
    @cart.update(total_price: 0)
  end

  def checkout
    return false unless @cart.cart_items.any?

    # This would integrate with your checkout process
    # Creating orders, processing payment, etc.
    true
  end
end
