require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when there are notes to fetch' do
        let(:expected_keys) { %w[id title note_type content_length].freeze }

        let!(:review_notes) { create_list(:note, 3, note_type: 'review', user: user) }
        let!(:critique_notes) { create_list(:note, 7, note_type: 'critique', user: user) }
        let(:user_notes) { review_notes + critique_notes }

        let(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: NoteSerializer).as_json
        end

        before { get :index, params: params }

        context 'when fetching all the notes' do
          let(:notes_expected) { user_notes }
          let(:params) { {} }

          it_behaves_like 'successfull request array response'
        end

        context 'when fetching notes with page and page size params' do
          let(:page) { 1 }
          let(:page_size) { 2 }
          let(:notes_expected) { user_notes.first(2) }
          let(:params) { { page: page, page_size: page_size } }

          it_behaves_like 'successfull request array response'
        end

        context 'when fetching notes using note_type filter' do
          context 'when Review' do
            let(:notes_expected) { review_notes }
            let(:params) { { note_type: 'review' } }

            it_behaves_like 'successfull request array response'
          end

          context 'when Critique' do
            let(:notes_expected) { critique_notes }
            let(:params) { { note_type: 'critique' } }

            it_behaves_like 'successfull request array response'
          end

          context 'when invalid note_type filter' do
            let(:notes_expected) { critique_notes }
            let(:params) { { note_type: 'invalid_type' } }

            let(:message) { I18n.t('activerecord.errors.messages.invalid_attribute') }

            it_behaves_like 'unprocessable entity with message'
          end
        end

        context 'when sorting notes' do
          context 'with creation order' do
            let(:sorted_notes) { user_notes.sort_by(&:created_at) }

            context 'when asc' do
              let(:notes_expected) { sorted_notes }
              let(:params) { { order: 'asc' } }

              it_behaves_like 'successfull request array response'
            end

            context 'when desc' do
              let(:notes_expected) { sorted_notes.reverse }
              let(:params) { { order: 'desc' } }

              it_behaves_like 'successfull request array response'
            end

            context 'when invalid sort value' do
              let(:notes_expected) { sorted_notes }
              let(:params) { { order: 'ascendent' } }

              it_behaves_like 'successfull request array response'
            end
          end
        end

        context 'when fetching notes using creation order and type filter' do
          let(:notes_expected) { review_notes.sort_by(&:created_at).reverse }
          let(:params) { { note_type: 'review', order: 'desc' } }

          it_behaves_like 'successfull request array response'
        end
      end

      context 'when there are no notes to fetch' do
        let(:expected) { [] }

        before { get :index }

        it_behaves_like 'successfull request array response'
      end
    end

    context 'when there is not a user logged in' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end

  describe ' GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      before { get :show, params: params }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }
        let(:expected) { NoteDetailSerializer.new(note, root: false).to_json }
        let(:params) { { id: note.id } }

        it_behaves_like 'successfull request object response'
      end

      context 'when fetching an invalid note' do
        let(:params) { { id: Faker::Number.number } }

        let(:message) { I18n.t('activerecord.errors.messages.record_not_found') }

        it_behaves_like 'resource not found'
      end
    end

    context 'when there is not a user logged in' do
      before { get :show, params: { id: Faker::Number.number } }

      it_behaves_like 'unauthorized'
    end
  end
end
