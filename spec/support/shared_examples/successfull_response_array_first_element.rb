shared_examples 'successfull response array first element' do
  it 'matches id' do
    expect(response_body.first['id']).to eq(expected.first[:id])
  end
end
