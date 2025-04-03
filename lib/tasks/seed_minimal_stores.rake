namespace :db do
  namespace :seed do
    desc "Seed minimal stores data only (no dependencies)"
    task minimal_stores: :environment do
      puts "Seeding minimal stores..."
      load Rails.root.join('db/seeds/minimal_stores.rb')
      puts "Minimal stores seeded successfully!"
    end
  end
end
