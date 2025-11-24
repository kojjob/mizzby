require "application_system_test_case"

class PaymentAuditLogsTest < ApplicationSystemTestCase
  setup do
    @payment_audit_log = payment_audit_logs(:one)
  end

  test "visiting the index" do
    visit payment_audit_logs_url
    assert_selector "h1", text: "Payment audit logs"
  end

  test "should create payment audit log" do
    visit payment_audit_logs_url
    click_on "New payment audit log"

    fill_in "Amount", with: @payment_audit_log.amount
    fill_in "Event type", with: @payment_audit_log.event_type
    fill_in "Ip address", with: @payment_audit_log.ip_address
    fill_in "Metadata", with: @payment_audit_log.metadata
    fill_in "Order", with: @payment_audit_log.order_id
    fill_in "Payment processor", with: @payment_audit_log.payment_processor
    fill_in "Transaction", with: @payment_audit_log.transaction_id
    fill_in "User agent", with: @payment_audit_log.user_agent
    fill_in "User", with: @payment_audit_log.user_id
    click_on "Create Payment audit log"

    assert_text "Payment audit log was successfully created"
    click_on "Back"
  end

  test "should update Payment audit log" do
    visit payment_audit_log_url(@payment_audit_log)
    click_on "Edit this payment audit log", match: :first

    fill_in "Amount", with: @payment_audit_log.amount
    fill_in "Event type", with: @payment_audit_log.event_type
    fill_in "Ip address", with: @payment_audit_log.ip_address
    fill_in "Metadata", with: @payment_audit_log.metadata
    fill_in "Order", with: @payment_audit_log.order_id
    fill_in "Payment processor", with: @payment_audit_log.payment_processor
    fill_in "Transaction", with: @payment_audit_log.transaction_id
    fill_in "User agent", with: @payment_audit_log.user_agent
    fill_in "User", with: @payment_audit_log.user_id
    click_on "Update Payment audit log"

    assert_text "Payment audit log was successfully updated"
    click_on "Back"
  end

  test "should destroy Payment audit log" do
    visit payment_audit_log_url(@payment_audit_log)
    accept_confirm { click_on "Destroy this payment audit log", match: :first }

    assert_text "Payment audit log was successfully destroyed"
  end
end
