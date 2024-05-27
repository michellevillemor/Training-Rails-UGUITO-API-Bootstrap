shared_examples 'bad request when a parameter is missing' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an error message' do
    expected_errors = response_body['errors'].map { |error| error['detail'] }
    expected_messages = missing_attributes.map do |attribute|
      I18n.t("activerecord.errors.#{model}.invalid_attribute.#{attribute}")
    end

    expect(expected_errors).to all(be_in(expected_messages))
  end
end
