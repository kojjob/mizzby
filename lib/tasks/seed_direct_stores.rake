namespace :db do
  namespace :seed do
    desc "Seed stores directly (bypassing associations)"
    task direct_stores: :environment do
      puts "Seeding direct stores..."
      load Rails.root.join("db/seeds/direct_stores.rb")
      puts "Direct stores seeded successfully!"
    end
  end
end
