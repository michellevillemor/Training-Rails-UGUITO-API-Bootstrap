FactoryBot.define do
  factory :note do
    user
    title { Faker::Lorem.sentence(word_count: 5) }
    content { Faker::Lorem.sentence(word_count: 5) }
    note_type { 'critique' }
  end
end
