namespace :db do
  namespace :seed do
    desc "Seed stores only (minimal dependencies)"
    task stores_only: :environment do
      puts "Seeding stores only..."
      load Rails.root.join('db/seeds/stores_only.rb')
      puts "Stores seeded successfully!"
    end
  end
end
