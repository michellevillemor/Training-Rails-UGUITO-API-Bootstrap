shared_examples 'unprocessable entity with message' do
  it 'returns status code unprocessable entity' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns the appropiate error message' do
    if response_body['errors']
      expect(response_body['errors'].first['detail']).to eq(message)
    else
      expect(response_body['error']).to eq(message)
    end
  end
end
