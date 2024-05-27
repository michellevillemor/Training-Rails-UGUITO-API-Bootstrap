require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  let(:expected_keys) { NoteSerializer::EXPECTED_KEYS }

  describe 'GET #index' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:review_notes) { create_list(:note, 3, note_type: 'review', user: user) }
      let!(:critique_notes) { create_list(:note, 7, note_type: 'critique', user: user) }
      let(:user_notes) { review_notes + critique_notes }

      let(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: NoteSerializer).as_json
      end

      context 'when fetching all the notes for user' do
        let(:notes_expected) { user_notes }

        before { get :index }

        it_behaves_like 'successfull request array response'
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { user_notes.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it_behaves_like 'successfull request array response'
      end

      context 'when fetching notes using note_type filter' do
        context 'when Review' do
          let(:notes_expected) { review_notes }

          before { get :index, params: { type: 'review' } }

          it_behaves_like 'successfull request array response'
        end

        context 'when Critique' do
          let(:notes_expected) { critique_notes }

          before { get :index, params: { type: 'critique' } }

          it_behaves_like 'successfull request array response'
        end

        context 'when invalid note_type filter' do
          let(:notes_expected) { critique_notes }

          before { get :index, params: { type: 'invalid_type' } }

          it 'responds with 422 status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when sorting notes' do
        context 'with creation order' do
          let(:sorted_notes) { user_notes.sort_by(&:created_at) }

          context 'when asc' do
            let(:notes_expected) { sorted_notes }

            before { get :index, params: { order: 'asc' } }

            it_behaves_like 'successfull request array response'
          end

          context 'when desc' do
            let(:notes_expected) { sorted_notes.reverse }

            before { get :index, params: { order: 'desc' } }

            it_behaves_like 'successfull request array response'
          end

          context 'when invalid sort value' do
            let(:notes_expected) { sorted_notes }

            before { get :index, params: { order: 'ascendent' } }

            it 'responds with 422 status' do
              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end

      context 'when fetching notes using creation order and type filter' do
        let(:notes_expected) { review_notes.sort_by(&:created_at).reverse }

        before { get :index, params: { order: 'desc', type: 'review' } }

        it_behaves_like 'successfull request array response'
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe ' GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }
        let(:expected) { NoteDetailSerializer.new(note, root: false).to_json }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'successfull request object response'
      end

      context 'when fetching an invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        note: {
          title: 'Reseña',
          note_type: 'review',
          content: Faker::Lorem.sentence(word_count: 5)
        }
      }
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when the note is created successfully' do
        before { post :create, params: valid_attributes }

        let(:message) { I18n.t('activerecord.success.create', { resource: I18n.t('activerecord.models.note') }) }

        it_behaves_like 'success post request with message'
      end

      context 'when required parameters are missing' do
        let(:model) { 'note' }
        let(:missing_attributes) do
          [:title]
        end
        let(:params) do
          {
            model => {
              content: 'esto es un contenido'
            }
          }
        end

        before { post :create, params: params }

        it_behaves_like 'bad request when a parameter is missing'
      end

      context 'when the note type is invalid' do
        let(:params) do
          {
            note: {
              title: Faker::Lorem.word,
              note_type: 'invalid_type',
              content: Faker::Lorem.sentence(word_count: 5)
            }
          }
        end
        let(:expected_message) { I18n.t('errors.messages.invalid_attribute.note_type') }

        before { post :create, params: params }

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when the note content length exceeds the limit for reviews' do
        utility = Utility.new(type: %w[NorthUtility SouthUtility].sample)

        let(:params) do
          {
            note: {
              title: 'Reseña',
              note_type: 'review',
              content: Faker::Lorem.sentence(word_count: 150),
              utility: utility
            }
          }
        end
        let(:message) { I18n.t('activerecord.errors.note.invalid_attribute.content_length', { note_type: 'review', threshold: utility.content_short_length }) }

        before { post :create, params: params }

        it_behaves_like 'bad request with message'
      end
    end

    context 'when there is not a user logged in' do
      before { post :create, params: valid_attributes }

      it_behaves_like 'unauthorized'
    end
  end
end
