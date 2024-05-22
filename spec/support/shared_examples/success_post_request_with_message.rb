shared_examples 'success post request with message' do
    it 'returns status code ok' do
      expect(response).to have_http_status(:created)
    end
  
    it 'returns the success message' do
      expect(response_body['message']).to eq(message)
    end
end
  