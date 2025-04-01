module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [ :show, :edit, :update, :destroy, :process_payment, :refund, :download_invoice ]
    before_action -> { authorize_action(:manage_orders) }
    before_action -> { authorize_action(:issue_refunds) }, only: [ :refund ]

    def index
      @orders = Order.includes(:user, :product)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(25)

      # Filter by status
      @orders = @orders.where(status: params[:status]) if params[:status].present?

      # Filter by payment processor
      if params[:payment_processor].present?
        @orders = @orders.where(payment_processor: params[:payment_processor])
      end

      # Filter by payment status
      if params[:payment_status].present?
        @orders = @orders.where(payment_status: params[:payment_status])
      end

      # Filter by user
      @orders = @orders.where(user_id: params[:user_id]) if params[:user_id].present?

      # Filter by product
      @orders = @orders.where(product_id: params[:product_id]) if params[:product_id].present?

      # Filter by date range
      if params[:start_date].present?
        start_date = Date.parse(params[:start_date]).beginning_of_day
        @orders = @orders.where("created_at >= ?", start_date)
      end

      if params[:end_date].present?
        end_date = Date.parse(params[:end_date]).end_of_day
        @orders = @orders.where("created_at <= ?", end_date)
      end

      # Search by order ID or payment ID
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @orders = @orders.where("id::text ILIKE ? OR payment_id ILIKE ?", search_term, search_term)
      end

      # Calculate stats for filtered orders
      @stats = {
        total_orders: @orders.size,
        total_revenue: @orders.sum(:total_amount),
        avg_order_value: @orders.average(:total_amount).to_f.round(2),
        completed_count: @orders.where(status: "completed").count,
        pending_count: @orders.where(status: "pending").count
      }
    end

    def show
      @payment_logs = @order.payment_audit_logs.order(created_at: :desc)
      @download_links = @order.download_links.includes(:product) if @order.product&.is_digital?
    end

    def edit
    end

    def update
      if @order.update(order_params)
        # Create a log entry for the update
        @order.payment_audit_logs.create(
          user: current_user,
          event_type: "order_update",
          payment_processor: @order.payment_processor,
          amount: @order.total_amount,
          transaction_id: @order.payment_id,
          metadata: { changes: @order.previous_changes }.to_json,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        flash[:success] = "Order was successfully updated."
        redirect_to admin_order_path(@order)
      else
        flash.now[:error] = "There was a problem updating the order."
        render :edit
      end
    end

    def destroy
      if @order.destroy
        flash[:success] = "Order was successfully deleted."
      else
        flash[:error] = "Order could not be deleted: #{@order.errors.full_messages.join(', ')}"
      end

      redirect_to admin_orders_path
    end

    def process_payment
      # Only process pending payments
      unless @order.payment_status == "pending"
        flash[:error] = "Cannot process payment that is not in pending status."
        return redirect_to admin_order_path(@order)
      end

      # Simulate payment processing
      success = rand > 0.1 # 90% success rate for demo

      if success
        @order.update(
          payment_status: "paid",
          status: "completed"
        )

        # Create a payment log
        @order.payment_audit_logs.create(
          user: current_user,
          event_type: "manual_payment_approval",
          payment_processor: @order.payment_processor,
          amount: @order.total_amount,
          transaction_id: @order.payment_id,
          metadata: { approved_by: current_user.id }.to_json,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        # Create download links if it's a digital product
        if @order.product&.is_digital?
          @order.create_download_link
        end

        flash[:success] = "Payment has been marked as processed successfully."
      else
        @order.update(
          payment_status: "failed",
          status: "cancelled"
        )

        # Create a payment log
        @order.payment_audit_logs.create(
          user: current_user,
          event_type: "manual_payment_failure",
          payment_processor: @order.payment_processor,
          amount: @order.total_amount,
          transaction_id: @order.payment_id,
          metadata: { reason: "Manual processing failed" }.to_json,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        flash[:error] = "Payment processing failed."
      end

      redirect_to admin_order_path(@order)
    end

    def refund
      # Only refund paid orders
      unless @order.payment_status == "paid"
        flash[:error] = "Cannot refund an order that has not been paid."
        return redirect_to admin_order_path(@order)
      end

      # Simulate refund processing
      success = rand > 0.1 # 90% success rate for demo

      if success
        @order.update(
          payment_status: "refunded",
          status: "refunded"
        )

        # Create a payment log
        @order.payment_audit_logs.create(
          user: current_user,
          event_type: "refund",
          payment_processor: @order.payment_processor,
          amount: @order.total_amount,
          transaction_id: @order.payment_id,
          metadata: { refunded_by: current_user.id, reason: params[:reason] }.to_json,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        # Deactivate download links if it's a digital product
        if @order.product&.is_digital?
          @order.download_links.update_all(active: false)
        end

        flash[:success] = "Refund has been processed successfully."
      else
        flash[:error] = "Refund processing failed."
      end

      redirect_to admin_order_path(@order)
    end

    def download_invoice
      # Generate invoice PDF (placeholder for actual implementation)
      pdf_data = generate_invoice_pdf(@order)

      # Return the PDF for download
      send_data pdf_data,
                filename: "invoice-#{@order.id}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(
        :status, :payment_status, :payment_processor, :payment_details, :notes
      )
    end

    def generate_invoice_pdf(order)
      # This would normally use a PDF generation gem like Prawn
      # For demo purposes, just return a placeholder PDF
      "This is a placeholder for order ##{order.id} invoice PDF"
    end
  end
end
