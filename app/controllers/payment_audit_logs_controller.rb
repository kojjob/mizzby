class PaymentAuditLogsController < ApplicationController
  before_action :set_payment_audit_log, only: %i[ show edit update destroy ]

  # GET /payment_audit_logs or /payment_audit_logs.json
  def index
    @payment_audit_logs = PaymentAuditLog.all
  end

  # GET /payment_audit_logs/1 or /payment_audit_logs/1.json
  def show
  end

  # GET /payment_audit_logs/new
  def new
    @payment_audit_log = PaymentAuditLog.new
  end

  # GET /payment_audit_logs/1/edit
  def edit
  end

  # POST /payment_audit_logs or /payment_audit_logs.json
  def create
    @payment_audit_log = PaymentAuditLog.new(payment_audit_log_params)

    respond_to do |format|
      if @payment_audit_log.save
        format.html { redirect_to @payment_audit_log, notice: "Payment audit log was successfully created." }
        format.json { render :show, status: :created, location: @payment_audit_log }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment_audit_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_audit_logs/1 or /payment_audit_logs/1.json
  def update
    respond_to do |format|
      if @payment_audit_log.update(payment_audit_log_params)
        format.html { redirect_to @payment_audit_log, notice: "Payment audit log was successfully updated." }
        format.json { render :show, status: :ok, location: @payment_audit_log }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment_audit_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_audit_logs/1 or /payment_audit_logs/1.json
  def destroy
    @payment_audit_log.destroy!

    respond_to do |format|
      format.html { redirect_to payment_audit_logs_path, status: :see_other, notice: "Payment audit log was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_audit_log
      @payment_audit_log = PaymentAuditLog.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_audit_log_params
      params.expect(payment_audit_log: [ :user_id, :order_id, :event_type, :payment_processor, :amount, :transaction_id, :metadata, :ip_address, :user_agent ])
    end
end
