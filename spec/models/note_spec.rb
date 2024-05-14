require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:north_utility_user_id) { User.where(email: 'test_north@widergy.com').pluck(:id) }
  let(:south_utility_user_id) { User.where(email: 'test_south@widergy.com').pluck(:id)  }

  subject(:note) do
    create(:note)
  end

  # %i[user_id title content note_type].each do |value|
  #   it { is_expected.to validate_presence_of(value) }
  # end

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  # describe 'Success' do
  #   let(:valid_north_review) { Array.new(50,"valid").join(' ') }
  #   let(:valid_south_review) { Array.new(60,"valid").join(' ') }

  #   it 'creates a valid review for north utility' do
  #     note = create(:note, note_type: 'review', content: valid_north_review, user_id: north_utility_user_id)
  #     expect(note).to eq({})
  #   end

  #   it 'creates a valid review for south utility' do
  #     note = create(:note, note_type: 'review', content: valid_south_review, user_id: south_utility_user_id)
  #     expect(note).to eq({})
  #   end

  #   it 'creates a valid critique' do
  #     note = create(:note, note_type: 'critique', content: critique, user_id: north_utility_user_id)
  #     expect(note).to eq({})
  #   end
  # end

  # describe 'Fails' do
  #   let(:invalid_north_review) { Array.new(51,"invalid").join(' ') }
  #   let(:invalid_south_review) { Array.new(61,"invalid").join(' ') }

  #   it 'throws error when creating an invalid review for north utility' do
  #     note = create(:note, note_type: 'review', content: invalid_north_review, user_id: north_utility_user_id)
  #   end

  #   it 'throws error when creating an invalid review for south utility' do
  #     note = create(:note, note_type: 'review', content: invalid_south_review, user_id: south_utility_user_id)
  #   end
  # end
end