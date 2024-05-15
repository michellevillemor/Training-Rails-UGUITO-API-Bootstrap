require 'rails_helper'

RSpec.describe Note, type: :model do
 
  subject(:note) do
    create(:note)
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to belong_to(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'when content size is within thresholds' do
    let(:valid_north_review) { Array.new(50,"valid").join(' ') }
    let(:valid_south_review) { Array.new(60,"valid").join(' ') }
    let(:critique) { Array.new(70,"valid").join(' ') }

    it 'creates a valid review for north utility' do
      expected = { title: 'Esto es una nota', content: valid_north_review, note_type: 'review', user_id: 1 }

      custom_utility = create(:utility, type: 'NorthUtility')
      note = create(:note, content: valid_north_review, utility: custom_utility, user_id: 1)

      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end

    it 'creates a valid review for south utility' do
      expected = { title: 'Esto es una nota', content: valid_south_review, note_type: 'review'}

      custom_utility = create(:utility, type: 'SouthUtility')
      note = create(:note, content: valid_south_review, utility: custom_utility, user_id: 1)

      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end

    it 'creates a valid critique' do
      expected = { title: 'Esto es una nota', content: critique, note_type: 'critique'}
      note = create(:note, note_type: 'critique', content: critique, user_id: 1)
      
      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end
  end

  context 'when content size exceeds threshold'  do
    let(:invalid_north_review) { Array.new(51,"north").join(' ') }
    let(:invalid_south_review) { Array.new(61,"invalid").join(' ') }

    it 'throws error when creating an invalid review for north utility' do
      custom_utility = create(:utility, type: 'NorthUtility')
      binding.pry
      note = create(:note, utility: custom_utility)

      expect(note).to raise_error("The content of the review is bigger than 60 for North Utility")
    end

    it 'throws error when creating an invalid review for south utility' do
      custom_utility = create(:utility, type: 'SouthUtility')
      note = create(:note, utility: custom_utility)

      expect(note).to raise_error("The content of the review is bigger than 50 for South Utility")
    end
  end
end
