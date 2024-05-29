shared_examples 'unprocessable entity with message' do
  it 'returns status code unprocessable entity' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns the appropiate error message' do
    binding.pry
    errors = response_body['errors'].map { |error| error['detail'] }

    expect(errors).to all(include(expected_message))
  end
end
