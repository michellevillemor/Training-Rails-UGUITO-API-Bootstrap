require 'rails_helper'

RSpec.shared_examples 'a valid note' do |content, note_type, utility_type|
  it "creates a valid #{note_type} note for #{utility_type}" do
    utility = create(:utility, type: utility_type)
    note = create(:note, content: content, note_type: note_type, utility: utility)
    
    expect(note).not_to be nil
  end
end

RSpec.shared_examples 'a invalid note' do |content, note_type, utility_type|
  it "throws error when creating an invalid #{note_type} for #{utility_type}" do
    utility = create(:utility, type: utility_type)
    
    expect do
      create(:note, content: content, note_type: note_type, utility: utility)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { expect(subject).to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it 'can access utility through user' do
      utility = create(:utility)
      user = create(:user, utility: utility)
      note = create(:note, user: user, utility: utility)

      expect(note.utility).to eq(utility)
    end
  end

  describe '#word_count' do
    let(:content_with_words) { Faker::Lorem.sentence(word_count: 5) }

    it 'counts words in content' do     
      note = create(:note, content: content_with_words)

      expect(note.word_count).to eq(5)
    end
  end

  describe '#validate_content_length' do
    context 'when content size is within thresholds' do
      valid_short_north_review = Faker::Lorem.sentence(word_count: 50)
      valid_short_south_review = Faker::Lorem.sentence(word_count: 60)
      valid_short_north_critique = Faker::Lorem.sentence(word_count: 50)
      valid_medium_north_critique = Faker::Lorem.sentence(word_count: 100)
      valid_long_north_critique = Faker::Lorem.sentence(word_count: 101)
      valid_short_south_critique = Faker::Lorem.sentence(word_count: 60)
      valid_medium_south_critique = Faker::Lorem.sentence(word_count: 120)
      valid_long_south_critique = Faker::Lorem.sentence(word_count: 121)
      
      include_examples 'a valid note', valid_short_north_review, 'review', 'NorthUtility'
      include_examples 'a valid note', valid_short_south_review, 'review', 'SouthUtility'
      include_examples 'a valid note', valid_short_north_critique, 'critique', 'NorthUtility'
      include_examples 'a valid note', valid_medium_north_critique, 'critique', 'NorthUtility'
      include_examples 'a valid note', valid_long_north_critique, 'critique', 'NorthUtility'
      include_examples 'a valid note', valid_short_south_critique, 'critique', 'SouthUtility'
      include_examples 'a valid note', valid_medium_south_critique, 'critique', 'SouthUtility'
      include_examples 'a valid note', valid_long_south_critique, 'critique', 'SouthUtility'
    end

    context 'when content size exceeds threshold' do
      invalid_medium_north_review = Faker::Lorem.sentence(word_count: 51)
      invalid_long_north_review = Faker::Lorem.sentence(word_count: 101)
      invalid_medium_south_review = Faker::Lorem.sentence(word_count: 61)
      invalid_long_south_review = Faker::Lorem.sentence(word_count: 121)

      include_examples 'a invalid note', invalid_medium_north_review, 'review', 'NorthUtility'
      include_examples 'a invalid note', invalid_long_north_review, 'review', 'NorthUtility'
      include_examples 'a invalid note', invalid_medium_south_review, 'review', 'SouthUtility'
      include_examples 'a invalid note', invalid_long_south_review, 'review', 'SouthUtility'
    end
  end

  
end
