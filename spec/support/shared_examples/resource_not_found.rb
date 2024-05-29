shared_examples 'resource not found' do
  it 'returns status code not found' do
    expect(response).to have_http_status(:not_found)
  end

  it 'returns the appropiate error message' do
    expect(response_body['error'])
      .to eq(message)
  end
end
