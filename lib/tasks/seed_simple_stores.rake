namespace :db do
  namespace :seed do
    desc "Seed simple stores data only"
    task simple_stores: :environment do
      puts "Seeding simple stores..."
      load Rails.root.join('db/seeds/simple_stores.rb')
      puts "Simple stores seeded successfully!"
    end
  end
end
