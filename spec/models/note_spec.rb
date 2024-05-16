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
    let(:valid_north_review) { Array.new(50, 'valid').join(' ') }
    let(:valid_south_review) { Array.new(60, 'valid').join(' ') }
    let(:critique) { Array.new(70, 'valid').join(' ') }

    it 'creates a valid review for north utility' do
      expected = { title: 'Esto es una nota', content: valid_north_review, note_type: 'review' }

      custom_utility = create(:utility, type: 'NorthUtility')

      note = create(:note, content: valid_north_review, utility: custom_utility)

      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end

    it 'creates a valid review for south utility' do
      expected = { title: 'Esto es una nota', content: valid_south_review, note_type: 'review' }

      custom_utility = create(:utility, type: 'SouthUtility')

      note = create(:note, content: valid_south_review, utility: custom_utility)

      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end

    it 'creates a valid critique' do
      expected = { title: 'Esto es una nota', content: critique, note_type: 'critique' }
      note = create(:note, note_type: 'critique', content: critique)

      expect(note.attributes.symbolize_keys.slice(:title, :content, :note_type)).to eq(expected)
    end
  end

  context 'when content size exceeds threshold' do
    let(:invalid_north_review) { Array.new(51, 'invalid').join(' ') }
    let(:invalid_south_review) { Array.new(61, 'invalid').join(' ') }

    it 'throws error when creating an invalid review for north utility' do
      north_utility = create(:utility, type: 'NorthUtility', name:'North Utility')

      expect do
        create(:note, utility: north_utility, content: invalid_north_review)
      end.to raise_error('La validación falló: El contenido de la review es mayor a 50 para North Utility')
    end

    it 'throws error when creating an invalid review for south utility' do
      south_utility = create(:utility, type: 'SouthUtility', name:'South Utility')

      expect do
        create(:note, utility: south_utility, content: invalid_south_review)
      end.to raise_error('La validación falló: El contenido de la review es mayor a 60 para South Utility')
    end
  end
end
