require 'rails_helper'

shared_examples 'a valid note' do
  it 'and passes validation' do
    note = described_class.new(note_type: note_type, utility: utility)
    note.validate_content_length
    expect(note.errors).to be_empty
  end
end

shared_examples 'an invalid note' do
  it 'and not passes validation' do
    note = described_class.new(note_type: note_type, utility: utility)
    note.validate_content_length
    expect(note.errors).not_to be_empty
  end
end

shared_examples 'content length' do
  it "" do
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
    let(:random_word_count) { Faker::Number.within(range: 1..50)}
    let(:content_with_words) { Faker::Lorem.sentence(word_count: random_word_count) }

    it 'counts words in content' do
      note = build(:note, content: content_with_words)

      expect(note.word_count).to eq(random_word_count)
    end
  end

  describe '#content_length' do
    context 'with North Utility' do 
      let(:utility) { build(:north_utility) }

      context 'when content is short' do
        let(:word_count) { 5 }
        let(:expected) { 'short' }

        it_behaves_like 'content length'
      end

      context 'when content is medium' do
        let(:word_count) { 80 }
        let(:expected) { 'medium' }

        it_behaves_like 'content length'
      end

      context 'when content is long' do
        let(:word_count) { 120 }
        let(:expected) { 'long' }

        it_behaves_like 'content length'
      end
    end

    context 'with South Utility' do 
      let(:utility) { build(:south_utility) }

      context 'when content is short' do
        let(:word_count) { 5 }
        let(:expected) { 'short' }

        it_behaves_like 'content length'
      end

      context 'when content is medium' do
        let(:word_count) { 110 }
        let(:expected) { 'medium' }

        it_behaves_like 'content length'
      end

      context 'when content is long' do
        let(:word_count) { 150 }
        let(:expected) { 'long' }

        it_behaves_like 'content length'
      end
    end
  end

  describe '#validate_content_length' do
    context 'when note_type is Review' do
      let(:note_type) { 'review' }

      context 'with North Utility' do
        let(:utility) { build(:north_utility) }

        context 'when short content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('short')
          end
          
          it_behaves_like 'a valid note'
        end

        context 'when medium content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('medium')
          end

          it_behaves_like 'an invalid note'
        end

        context 'when long content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('long')
          end

          it_behaves_like 'an invalid note'
        end
      end

      context 'with South Utility' do
        let(:utility) { build(:south_utility) }

        context 'when short content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('short')
          end
          
          it_behaves_like 'a valid note'
        end

        context 'when medium content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('medium')
          end

          it_behaves_like 'an invalid note'
        end

        context 'when long content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('long')
          end

          it_behaves_like 'an invalid note'
        end
      end
    end

    context 'when note_type is Critique' do
      let(:note_type) { 'critique' }

      context 'with North Utility' do
        let(:utility) { build(:north_utility) }

        context 'when short content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('short')
          end
          
          it_behaves_like 'a valid note'
        end

        context 'when medium content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('medium')
          end

          it_behaves_like 'a valid note'
        end

        context 'when long content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('long')
          end

          it_behaves_like 'a valid note'
        end
      end

      context 'with South Utility' do
        let(:utility) { build(:south_utility) }

        context 'when short content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('short')
          end

          it_behaves_like 'a valid note'
        end

        context 'when medium content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('medium')
          end

          it_behaves_like 'a valid note'
        end

        context 'when long content' do
          before do
            allow_any_instance_of(described_class).to receive(:content_length).and_return('long')
          end

          it_behaves_like 'a valid note'
        end
      end
    end
  end
end
