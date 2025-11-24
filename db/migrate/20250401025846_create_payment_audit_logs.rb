class CreatePaymentAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.string :event_type
      t.string :payment_processor
      t.decimal :amount
      t.string :transaction_id
      t.text :metadata
      t.inet :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
