# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: -> { "Mizzby <orders@#{default_host}>" }

  # Order confirmation email sent after successful payment
  def confirmation(order_ids, user_id)
    @user = User.find(user_id)
    @orders = Order.where(id: order_ids).includes(:product)
    @order = @orders.first # For payment info reference
    @total = @orders.sum(&:total_amount)
    
    # Separate digital and physical orders
    @digital_orders = @orders.select { |o| o.product&.is_digital? }
    @physical_orders = @orders.reject { |o| o.product&.is_digital? }
    
    mail(
      to: @user.email,
      subject: "Order Confirmed - #{@order.payment_id}"
    )
  end

  # Shipping notification email
  def shipped(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Your Order Has Shipped! - #{@order.payment_id}"
    )
  end

  # Delivery confirmation email
  def delivered(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Your Order Has Been Delivered - #{@order.payment_id}"
    )
  end

  # Refund notification email
  def refunded(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Refund Processed - #{@order.payment_id}"
    )
  end

  # Digital product download ready email
  def download_ready(order)
    @order = order
    @user = order.user
    @download_links = order.download_links.active
    
    mail(
      to: @user.email,
      subject: "Your Digital Download is Ready! - #{@order.product&.name}"
    )
  end

  private

  def default_host
    Rails.application.config.action_mailer.default_url_options&.dig(:host) || 'mizzby.com'
  end
end
