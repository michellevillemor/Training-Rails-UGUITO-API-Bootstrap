FactoryBot.define do
  factory :utility do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end
    content_short_length { 5 }
    content_medium_length { 10 }

    # Adds a number to the name to avoid duplicates and fail because of the uniqueness
    sequence(:name) { |n| "#{Faker::Lorem.word}#{n}" }
    type { Utility.subclasses.map(&:to_s).sample }
  end
end
