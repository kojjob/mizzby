class AddProductsCountToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :products_count, :integer, default: 0, null: false

    # Reset counter cache
    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    execute <<-SQL.squish
      UPDATE categories
        SET products_count = (
          SELECT COUNT(*)
          FROM products
          WHERE products.category_id = categories.id
        )
    SQL
  end
end
