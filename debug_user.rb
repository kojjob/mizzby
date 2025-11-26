user = User.new(
  first_name: "Test",
  last_name: "User",
  email: "test@example.com",
  password: "password",
  password_confirmation: "password"
)
user.valid?
puts "Errors: #{user.errors.full_messages}"

user_complex = User.new(
  first_name: "Test",
  last_name: "User",
  email: "complex@example.com",
  password: "Password1!",
  password_confirmation: "Password1!"
)
user_complex.valid?
puts "Complex Errors: #{user_complex.errors.full_messages}"
