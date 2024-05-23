FactoryBot.define do
  factory :note do
    user
    title { "Note n°#{Faker::Number.unique}" }
    content { Faker::Lorem.sentence(word_count: 5) }
    note_type { %w[review critique].sample }

    # Adds 1 min to created_at at each instance to avoid conflicts when order
    sequence(:created_at) { |n| Time.current + n.minutes }
  end
end
