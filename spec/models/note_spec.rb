require 'rails_helper'

shared_context 'with note setup' do |utility_type, _note_type, word_count|
  let(:utility) { create(:utility, type: utility_type.to_s) }
  let(:content) { Faker::Lorem.sentence(word_count: word_count) }
end

shared_examples 'a valid note' do |utility_type, note_type, word_count|
  include_context 'with note setup', utility_type, note_type, word_count

  it "creates a valid #{note_type} note for #{utility_type} with #{word_count} words" do
    note = create(:note, content: content, note_type: note_type, utility: utility)
    expect(note).not_to be nil
  end
end

shared_examples 'an invalid note' do |utility_type, note_type, word_count|
  include_context 'with note setup', utility_type, note_type, word_count

  it "throws error when creating an invalid #{note_type} for #{utility_type} with #{word_count} words" do
    expect { create(:note, content: content, note_type: note_type, utility: utility) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

shared_examples 'counts content length' do
  it "returns length string" do
    note = build(:note, content: Faker::Lorem.sentence(word_count: word_count), utility: utility)
    expect(note.content_length).to eq(expected)
  end
end

describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { expect(subject).to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it { is_expected.to have_one(:utility)}
  end

  describe 'enum note_type' do
    it { expect(note).to define_enum_for(:note_type).with_values(review: 0, critique: 1) }
  end

  describe '#word_count' do
    let(:random_word_count) { Faker::Number.number(digits: 2)}
    let(:content_with_words) { Faker::Lorem.sentence(word_count: random_word_count) }

    it 'counts words in content' do
      note = create(:note, content: content_with_words)

      expect(note.word_count).to eq(random_word_count)
    end
  end

  describe '#content_length' do
    context 'for North Utility' do 
      let(:utility) { build(:north_utility) }

      context 'when short content' do
        let(:word_count) { 5 }
        let(:expected) { 'short' }

        include_examples 'counts content length'
      end

      context 'when medium content' do
        let(:word_count) { 80 }
        let(:expected) { 'medium' }

        include_examples 'counts content length'
      end

      context 'when long content' do
        let(:word_count) { 120 }
        let(:expected) { 'long' }

        include_examples 'counts content length'
      end
    end

    context 'for South Utility' do 
      let(:utility) { build(:south_utility) }

      context 'when short content' do
        let(:word_count) { 5 }
        let(:expected) { 'short' }

        include_examples 'counts content length'
      end

      context 'when medium content' do
        let(:word_count) { 110 }
        let(:expected) { 'medium' }

        include_examples 'counts content length'
      end

      context 'when long content' do
        let(:word_count) { 150 }
        let(:expected) { 'long' }

        include_examples 'counts content length'
      end
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
              context "with valid content length" do
                include_examples 'a valid note', utility_type, note_type, word_count
              end
            end

            invalid_word_counts[utility_type][note_type].each do |word_count|
              context "with invalid content length" do
                include_examples 'an invalid note', utility_type, note_type, word_count
              end
            end
          end
        end
      end
    end
  end
end
