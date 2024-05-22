shared_examples 'bad request when a parameter is missing' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an error message' do
    expect(response_body['error']).to eq I18n.t('activerecord.errors.messages.internal_server_error')
  end
end
