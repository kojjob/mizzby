require "test_helper"

class PaymentAuditLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_audit_log = payment_audit_logs(:one)
  end

  test "should get index" do
    get payment_audit_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_audit_log_url
    assert_response :success
  end

  test "should create payment_audit_log" do
    assert_difference("PaymentAuditLog.count") do
      post payment_audit_logs_url, params: { payment_audit_log: { amount: @payment_audit_log.amount, event_type: @payment_audit_log.event_type, ip_address: @payment_audit_log.ip_address, metadata: @payment_audit_log.metadata, order_id: @payment_audit_log.order_id, payment_processor: @payment_audit_log.payment_processor, transaction_id: @payment_audit_log.transaction_id, user_agent: @payment_audit_log.user_agent, user_id: @payment_audit_log.user_id } }
    end

    assert_redirected_to payment_audit_log_url(PaymentAuditLog.last)
  end

  test "should show payment_audit_log" do
    get payment_audit_log_url(@payment_audit_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_audit_log_url(@payment_audit_log)
    assert_response :success
  end

  test "should update payment_audit_log" do
    patch payment_audit_log_url(@payment_audit_log), params: { payment_audit_log: { amount: @payment_audit_log.amount, event_type: @payment_audit_log.event_type, ip_address: @payment_audit_log.ip_address, metadata: @payment_audit_log.metadata, order_id: @payment_audit_log.order_id, payment_processor: @payment_audit_log.payment_processor, transaction_id: @payment_audit_log.transaction_id, user_agent: @payment_audit_log.user_agent, user_id: @payment_audit_log.user_id } }
    assert_redirected_to payment_audit_log_url(@payment_audit_log)
  end

  test "should destroy payment_audit_log" do
    assert_difference("PaymentAuditLog.count", -1) do
      delete payment_audit_log_url(@payment_audit_log)
    end

    assert_redirected_to payment_audit_logs_url
  end
end
