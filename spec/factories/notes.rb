FactoryBot.define do
  factory :note do
    user
    title { Faker::TvShows::DrWho.catch_phrase }
    content { Faker::Lorem.sentence(word_count: 5) }
    note_type { %w[review critique].sample }
  end
end
