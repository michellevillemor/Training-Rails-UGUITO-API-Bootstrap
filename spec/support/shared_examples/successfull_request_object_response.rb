shared_examples 'successfull request object response' do
  it 'responds with the expected json' do
    expect(response_body.to_json).to eq(expected)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
