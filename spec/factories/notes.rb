FactoryBot.define do
  factory :note do
    user
    title { 'Esto es una nota' }
    content { Faker::Lorem.sentence(word_count: 5) }
    note_type { 'review' }

    # Adds 1 min to created_at at each instance to avoid conflicts when order
    sequence(:created_at) { |n| Time.current + n.minutes }
  end
end
