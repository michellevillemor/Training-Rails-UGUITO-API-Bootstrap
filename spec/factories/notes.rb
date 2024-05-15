FactoryBot.define do
  factory :note do
    user
    title {'Esto es una nota'}
    content { Faker::Lorem.sentence(word_count: 5) }
    note_type { 'review' }
  end
end
