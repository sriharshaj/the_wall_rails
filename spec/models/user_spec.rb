require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create :user }

  it "username is not empty" do
    user.update(username: '')
    expect(user.errors).to include(:username)
  end

  it "email is not empty" do
    user.update(email: '')
    expect(user.errors).to include(:email)
  end

  it "username is not duplicate" do
    user1 = User.create(username: user.username,
      password: 'test', email: 't@example.com')
    expect(user1.errors).to include(:username)
  end

  it "email is not duplicate" do
    user1 = User.create(username: 'test1',
      password: 'test', email: user.email)
    expect(user1.errors).to include(:email)
  end
end
