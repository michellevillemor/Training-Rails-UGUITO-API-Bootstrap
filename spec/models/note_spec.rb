require 'rails_helper'

RSpec.shared_context 'with note setup' do |utility_type, _note_type, word_count|
  let(:utility) { create(:utility, type: utility_type.to_s) }
  let(:content) { Faker::Lorem.sentence(word_count: word_count) }
end

RSpec.shared_examples 'a valid note' do |utility_type, note_type, word_count|
  include_context 'with note setup', utility_type, note_type, word_count

  it "creates a valid #{note_type} note for #{utility_type} with #{word_count} words" do
    note = create(:note, content: content, note_type: note_type, utility: utility)
    expect(note).not_to be nil
  end
end

RSpec.shared_examples 'an invalid note' do |utility_type, note_type, word_count|
  include_context 'with note setup', utility_type, note_type, word_count

  it "throws error when creating an invalid #{note_type} for #{utility_type} with #{word_count} words" do
    expect { create(:note, content: content, note_type: note_type, utility: utility) }.to raise_error(ActiveRecord::RecordInvalid)
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

  describe 'enum note_type' do
    it 'defines the correct enum values' do
      expect(described_class.note_types).to eq({ 'review' => 0, 'critique' => 1 })
    end

    it 'sets note_type to review' do
      note.update(note_type: 'review')
      expect(note.note_type).to eq('review')
    end

    it 'sets note_type to critique' do
      note.update(note_type: 'critique')
      expect(note.note_type).to eq('critique')
    end

    it 'raises an error when setting an invalid note_type' do
      expect { note.update!(note_type: 'invalid_type') }.to raise_error(ArgumentError)
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
    valid_word_counts = {
      NorthUtility: {
        review: [50],
        critique: [50, 100, 101]
      },
      SouthUtility: {
        review: [60],
        critique: [60, 120, 121]
      }
    }

    invalid_word_counts = {
      NorthUtility: {
        review: [51, 101],
        critique: []
      },
      SouthUtility: {
        review: [61, 121],
        critique: []
      }
    }

    %i[NorthUtility SouthUtility].each do |utility_type|
      context "for #{utility_type}" do
        %i[review critique].each do |note_type|
          context "when note_type is #{note_type}" do
            valid_word_counts[utility_type][note_type].each do |word_count|
              context "with valid content length of #{word_count} words" do
                include_examples 'a valid note', utility_type, note_type, word_count
              end
            end

            invalid_word_counts[utility_type][note_type].each do |word_count|
              context "with invalid content length of #{word_count} words" do
                include_examples 'an invalid note', utility_type, note_type, word_count
              end
            end
          end
        end
      end
    end
  end
end
