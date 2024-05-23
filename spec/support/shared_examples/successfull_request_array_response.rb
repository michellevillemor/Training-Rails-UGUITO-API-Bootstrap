shared_examples 'successfull request array response' do
  it 'responds with the expected keys and count' do
    expect(response_body).to be_an(Array)
    expect(response_body.size).to eq(expected.size)

    response_body.each do |item|
      expect(item.keys).to match_array(expected_keys)
    end
  end


  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
