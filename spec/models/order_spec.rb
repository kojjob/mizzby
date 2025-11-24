require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:product) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:download_links).dependent(:destroy) }
    it { should have_many(:payment_audit_logs).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:payment_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:product_id) }
    it { should validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      pending: 'pending',
      processing: 'processing',
      paid: 'paid',
      completed: 'completed',
      cancelled: 'cancelled',
      refunded: 'refunded'
    ).backed_by_column_of_type(:string) }

    it { should define_enum_for(:payment_status).with_values(
      pending_payment: 'pending',
      processing_payment: 'processing',
      payment_successful: 'paid',
      payment_failed: 'failed',
      payment_refunded: 'refunded'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:pending_order) { create(:order, status: 'pending') }
    let!(:completed_order) { create(:order, :completed) }
    let!(:cancelled_order) { create(:order, :cancelled) }
    let!(:paid_order) { create(:order, :paid) }

    describe '.pending_orders' do
      it 'returns only pending orders' do
        expect(Order.pending_orders).to include(pending_order)
        expect(Order.pending_orders).not_to include(completed_order)
      end
    end

    describe '.completed_orders' do
      it 'returns only completed orders' do
        expect(Order.completed_orders).to include(completed_order)
        expect(Order.completed_orders).not_to include(pending_order)
      end
    end

    describe '.cancelled_orders' do
      it 'returns only cancelled orders' do
        expect(Order.cancelled_orders).to include(cancelled_order)
        expect(Order.cancelled_orders).not_to include(pending_order)
      end
    end

    describe '.recent' do
      it 'returns orders in descending created_at order' do
        expect(Order.recent.first).to eq(cancelled_order)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_default_status' do
      let(:order) { build(:order, status: nil, payment_status: nil) }

      it 'sets default status before validation' do
        order.save
        expect(order.status).to eq('pending')
        expect(order.payment_status).to eq('pending')
      end
    end

    describe '#generate_download_links_for_digital_products' do
      context 'for digital product' do
        let(:digital_product) { create(:product, :digital) }
        let(:order) { build(:order, product: digital_product) }

        it 'creates download link after order creation' do
          expect { order.save }.to change(DownloadLink, :count).by(1)
        end

        it 'sets correct download link attributes' do
          order.save
          download_link = order.download_links.last

          expect(download_link.active).to be true
          expect(download_link.download_count).to eq(0)
          expect(download_link.download_limit).to eq(5)
          expect(download_link.expires_at).to be_within(1.minute).of(30.days.from_now)
        end
      end

      context 'for physical product' do
        let(:physical_product) { create(:product, is_digital: false) }
        let(:order) { build(:order, product: physical_product) }

        it 'does not create download link' do
          expect { order.save }.not_to change(DownloadLink, :count)
        end
      end
    end
  end

  describe '#process_payment!' do
    let(:order) { create(:order) }

    it 'updates status to processing' do
      order.process_payment!
      expect(order.status).to eq('processing')
      expect(order.payment_status).to eq('processing_payment')
    end
  end

  describe '#mark_as_paid!' do
    let(:order) { create(:order) }

    it 'updates status to paid' do
      order.mark_as_paid!
      expect(order.status).to eq('paid')
      expect(order.payment_status).to eq('paid')
    end
  end

  describe '#mark_as_completed!' do
    let(:order) { create(:order, :paid) }

    it 'updates status to completed' do
      order.mark_as_completed!
      expect(order.status).to eq('completed')
    end
  end

  describe '#cancel!' do
    let(:order) { create(:order) }

    it 'updates status to cancelled' do
      order.cancel!
      expect(order.status).to eq('cancelled')
    end
  end

  describe '#refund!' do
    let(:order) { create(:order, :paid) }

    it 'updates status to refunded' do
      order.refund!
      expect(order.status).to eq('refunded')
      expect(order.payment_status).to eq('refunded')
    end
  end
end
