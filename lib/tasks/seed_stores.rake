namespace :db do
  namespace :seed do
    desc "Seed stores data only"
    task stores: :environment do
      puts "Seeding stores..."
      load Rails.root.join('db/seeds/stores_only.rb')
      puts "Stores seeded successfully!"
    end
  end
end
