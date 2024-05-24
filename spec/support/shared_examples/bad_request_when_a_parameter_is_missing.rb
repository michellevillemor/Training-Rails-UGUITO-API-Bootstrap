shared_examples 'bad request when a parameter is missing' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an error message' do
    expected_errors = response_body['errors'].map { |error| error['detail'] }

    missing_attributes.each do |attribute, value|
      expected_message = I18n.t("activerecord.errors.#{model}.invalid_attribute.#{attribute}")
      expect(expected_errors).to include(expected_message)
    end
  end
end
