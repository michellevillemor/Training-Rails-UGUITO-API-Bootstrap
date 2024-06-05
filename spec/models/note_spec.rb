require 'rails_helper'

shared_examples 'a valid note' do
  it 'passes the content_length validation' do
    note = described_class.new(note_type: note_type, utility: utility)
    note.validate_content_length
    expect(note.errors).to be_empty
  end
end

shared_examples 'an invalid note' do
  it 'doesnt pass the content_length validation' do
    note = described_class.new(note_type: note_type, utility: utility)
    note.validate_content_length
    expect(note.errors).not_to be_empty
  end
end

shared_examples 'content length' do
  it 'returns the correct content length' do
    note = build(:note, content: Faker::Lorem.sentence(word_count: word_count), utility: utility)
    expect(note.content_length).to eq(expected)
  end
end

shared_examples 'content length cases for utility' do |word_count, expected|
  context "when content is #{expected}" do
    let(:word_count) { word_count }
    let(:expected) { expected }

    it_behaves_like 'content length'
  end
end

shared_examples 'validates review content length' do
  let(:valid_lengths) { %w[short] }
  let(:invalid_lengths) { %w[medium length] }

  context 'when valid length' do
    before do
      allow_any_instance_of(described_class).to receive(:content_length).and_return(valid_lengths.sample)
    end

    it_behaves_like 'a valid note'
  end

  context 'when indalid_length' do
    before do
      allow_any_instance_of(described_class).to receive(:content_length).and_return(invalid_lengths.sample)
    end

    it_behaves_like 'an invalid note'
  end
end

shared_examples 'validates critique content length' do
  let(:valid_lengths) { %w[short medium length] }

  before do
    allow_any_instance_of(described_class).to receive(:content_length).and_return(valid_lengths.sample)
  end

  it_behaves_like 'a valid note'
end

describe Note, type: :model do
  subject(:note) { create(:note) }

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { expect(subject).to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it { is_expected.to have_one(:utility) }
  end

  describe 'enum note_type' do
    it { expect(note).to define_enum_for(:note_type).with_values(review: 0, critique: 1) }
  end

  describe '#word_count' do
    let(:total_words) { Faker::Number.between(from: 1, to: 9) }
    let(:updated_content) { Faker::Lorem.sentence(word_count: total_words) }

    it 'counts words in content' do
      note.update(content: updated_content)
      expect(subject.word_count).to eq(total_words)
    end
  end

  describe '#content_length' do
    context 'with North Utility' do
      let(:utility) { build(:north_utility) }

      it_behaves_like 'content length cases for utility', 5, 'short'
      it_behaves_like 'content length cases for utility', 80, 'medium'
      it_behaves_like 'content length cases for utility', 120, 'long'
    end

    context 'with South Utility' do
      let(:utility) { build(:south_utility) }

      it_behaves_like 'content length cases for utility', 10, 'short'
      it_behaves_like 'content length cases for utility', 100, 'medium'
      it_behaves_like 'content length cases for utility', 150, 'long'
    end
  end

  describe '#validate_content_length' do
    context 'when note_type is Review' do
      let(:note_type) { 'review' }

      context 'with North Utility' do
        let(:utility) { build(:north_utility) }

        it_behaves_like 'validates review content length'
      end

      context 'with South Utility' do
        let(:utility) { build(:south_utility) }

        it_behaves_like 'validates review content length'
      end
    end

    context 'when note_type is Critique' do
      let(:note_type) { 'critique' }

      context 'with North Utility' do
        let(:utility) { build(:north_utility) }

        it_behaves_like 'validates critique content length'
      end

      context 'with South Utility' do
        let(:utility) { build(:south_utility) }

        it_behaves_like 'validates critique content length'
      end
    end
  end
end
