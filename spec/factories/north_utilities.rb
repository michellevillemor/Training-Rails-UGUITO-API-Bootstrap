FactoryBot.define do
  factory :north_utility, class: 'NorthUtility', parent: :utility do
    type { 'NorthUtility' }
    name { 'North Utility' }
    external_api_key { Faker::Lorem.word }
    external_api_secret { Faker::Lorem.word }
    content_short_length { 50 }
    content_medium_length { 100 }
    base_url do
      'https://private-bfc6a-widergytrainingnorthutilityapi.apiary-mock.com'
    end
    external_api_authentication_url do
      'token'
    end
    books_data_url do
      'libros'
    end
    notes_data_url do
      'notas'
    end
  end
end
