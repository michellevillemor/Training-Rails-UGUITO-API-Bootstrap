require 'rails_helper'

describe Api::V1::NotesController, type: :controller do

  describe 'GET #index' do
    before { get :index, params: params}

    context 'when there are notes to fetch' do
      let(:expected_keys) { %w[id title note_type content_length].freeze }

      let!(:review_notes) { create_list(:note, 3, note_type: 'review') }
      let!(:critique_notes) { create_list(:note, 7, note_type: 'critique') }
      let(:notes) { review_notes + critique_notes }

      let(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: NoteSerializer).as_json
      end

      context 'when fetching all the notes' do
        let(:notes_expected) { notes }

        it_behaves_like 'successfull request array response'
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { notes.first(2) }
        let(:params) { page: page, page_size: page_size }

        it_behaves_like 'successfull request array response'
      end

      context 'when fetching notes using note_type filter' do
        context 'when Review' do
          let(:notes_expected) { review_notes }
          let(:params) { type: 'review' }

          it_behaves_like 'successfull request array response'
        end

        context 'when Critique' do
          let(:notes_expected) { critique_notes }
          let(:params) { type: 'critique' }

          it_behaves_like 'successfull request array response'
        end

        context 'when invalid note_type filter' do
          let(:notes_expected) { critique_notes }
          let(:params) { type: 'invalid_type' }

          it_behaves_like 'unprocessable entity with message'
        end
      end

      context 'when sorting notes' do
        context 'with creation order' do
          let(:sorted_notes) { notes.sort_by(&:created_at) }

          context 'when asc' do
            let(:notes_expected) { sorted_notes }
            let(:params) { order: 'asc' }

            it_behaves_like 'successfull request array response'
          end

          context 'when desc' do
            let(:notes_expected) { sorted_notes.reverse }
            let(:params) { order: 'desc' }

            it_behaves_like 'successfull request array response'
          end

          context 'when invalid sort value' do
            let(:notes_expected) { sorted_notes }
            let(:params) { order: 'ascendent' }

            it_behaves_like 'unprocessable entity with message'
          end
        end
      end

      context 'when fetching notes using creation order and type filter' do
        let(:notes_expected) { review_notes.sort_by(&:created_at).reverse }
        let(:params) { order: 'desc', type: 'review' }

        it_behaves_like 'successfull request array response'
      end
    end

    context 'when there are no notes to fetch' do
      let(:notes_expected) { [] }

      before do
        Note.delete_all
        get :index
      end

      it_behaves_like 'successfull request array response'
    end
  end

  describe ' GET #show' do
    before { get :show, params: params}

    context 'when fetching a valid note' do
      let(:note) { create(:note) }
      let(:expected) { NoteDetailSerializer.new(note, root: false).to_json }
      let(:params) { id: note.id }

      it_behaves_like 'successfull request object response'
    end

    context 'when fetching an invalid note' do
      let(:params) { id: Faker::Number.number }

      it_behaves_like 'bad request with message'
    end
  end
end
