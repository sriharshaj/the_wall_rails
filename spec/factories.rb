FactoryBot.define do
  factory :user do
    username { Faker::Name.unique.first_name }
    email { Faker::Internet.unique.email }
    password { 'test_password' }
  end

  factory :post do
    body { Faker::Lorem.paragraph(sentence_count:20) }
  end
end
