shared_examples 'unprocessable entity with message' do
  it 'returns status code unprocessable entity' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns the appropiate error message' do
    error = response_body['error'] if response_body['error']
    error = response_body['errors'].first['detail'] if response_body['errors']

    expect(error).to eq(message)
  end
end
