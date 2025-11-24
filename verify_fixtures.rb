
require_relative 'config/environment'

puts "Checking fixtures..."
users = User.all
users.each do |user|
  if user.valid?
    puts "User #{user.email}: VALID"
  else
    puts "User #{user.email}: INVALID - #{user.errors.full_messages.join(', ')}"
  end
end
