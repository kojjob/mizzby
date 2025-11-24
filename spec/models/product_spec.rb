require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { should belong_to(:category) }
    it { should belong_to(:seller) }
    it { should have_many(:product_images).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:wishlist_items).dependent(:destroy) }
    it { should have_many(:download_links).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:product) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:brand) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:sku) }
    it { should validate_presence_of(:meta_title) }
    it { should validate_presence_of(:meta_description) }

    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:sku).case_insensitive }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'scopes' do
    let!(:active_product) { create(:product, status: 'active') }
    let!(:inactive_product) { create(:product, status: 'inactive') }
    let!(:featured_product) { create(:product, :featured, status: 'active') }
    let!(:on_sale_product) { create(:product, :on_sale, status: 'active') }
    let!(:digital_product) { create(:product, :digital, status: 'active') }

    describe '.active' do
      it 'returns only active products' do
        expect(Product.active).to include(active_product)
        expect(Product.active).not_to include(inactive_product)
      end
    end

    describe '.featured' do
      it 'returns only featured products' do
        expect(Product.featured).to include(featured_product)
        expect(Product.featured).not_to include(active_product)
      end
    end

    describe '.on_sale' do
      it 'returns only products on sale' do
        expect(Product.on_sale).to include(on_sale_product)
        expect(Product.on_sale).not_to include(active_product)
      end
    end

    describe '.digital' do
      it 'returns only digital products' do
        expect(Product.digital).to include(digital_product)
        expect(Product.digital).not_to include(active_product)
      end
    end

    describe '.physical' do
      it 'returns only physical products' do
        expect(Product.physical).to include(active_product)
        expect(Product.physical).not_to include(digital_product)
      end
    end
  end

  describe '#on_sale?' do
    context 'when product has discounted price less than regular price' do
      let(:product) { create(:product, price: 100, discounted_price: 80) }

      it 'returns true' do
        expect(product.on_sale?).to be true
      end
    end

    context 'when product has no discounted price' do
      let(:product) { create(:product, price: 100, discounted_price: nil) }

      it 'returns false' do
        expect(product.on_sale?).to be false
      end
    end

    context 'when discounted price equals regular price' do
      let(:product) { create(:product, price: 100, discounted_price: 100) }

      it 'returns false' do
        expect(product.on_sale?).to be false
      end
    end
  end

  describe '#discount_percentage' do
    let(:product) { create(:product, price: 100, discounted_price: 75) }

    it 'calculates correct discount percentage' do
      expect(product.discount_percentage).to eq(25.0)
    end

    context 'when no discount' do
      let(:product) { create(:product, price: 100, discounted_price: nil) }

      it 'returns 0' do
        expect(product.discount_percentage).to eq(0)
      end
    end
  end

  describe '#average_rating' do
    let(:product) { create(:product) }

    context 'with reviews' do
      before do
        create(:review, product: product, rating: 5)
        create(:review, product: product, rating: 4)
        create(:review, product: product, rating: 3)
      end

      it 'calculates correct average rating' do
        expect(product.average_rating).to eq(4.0)
      end
    end

    context 'without reviews' do
      it 'returns nil' do
        expect(product.average_rating).to be_nil
      end
    end
  end

  describe 'slug generation' do
    let(:product) { build(:product, name: 'Amazing Product', slug: nil) }

    it 'generates slug before validation' do
      product.save
      expect(product.slug).to eq('amazing-product')
    end

    context 'when slug already exists' do
      let!(:existing_product) { create(:product, name: 'Amazing Product') }
      let(:new_product) { build(:product, name: 'Amazing Product', slug: nil) }

      it 'appends number to make slug unique' do
        new_product.save
        expect(new_product.slug).to match(/amazing-product-\d+/)
      end
    end
  end
end
