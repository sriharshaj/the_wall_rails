require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create(username: 'test',
    password: 'test', email: 'test@example.com')}
  let(:post) {Post.create(body: 'La La la', user: user)}

  it "body is not empty" do
    post.update(body: '')
    expect(post.errors).to include(:body)
  end

  it "belongs to user" do
    expect(post.user).to eq(user)
  end
end
