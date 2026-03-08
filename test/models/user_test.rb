require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(email_address: "new@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(email_address: nil, password: "password123")
    assert_not user.valid?
  end

  test "email must be unique" do
    duplicate = User.new(email_address: users(:admin).email_address, password: "password123", password_confirmation: "password123")
    assert_not duplicate.valid?
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end
end
