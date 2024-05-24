shared_examples 'unprocessable entity with message' do
  it 'returns status code unprocessable entity' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns the appropiate error message' do
    errors = response_body['errors'].map { |error| error['detail'] }
    
    errors.each do |err|
      expect(err).to include(expected_message)
    end
  end
end
