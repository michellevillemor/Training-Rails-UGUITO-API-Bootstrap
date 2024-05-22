require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:review_notes) { create_list(:note, 3, note_type: 'review', user: user) }
      let!(:critique_notes) { create_list(:note, 7, note_type: 'critique', user: user) }
      let(:user_notes) { review_notes + critique_notes }

      let(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: IndexNoteSerializer).to_json
      end

      context 'when fetching all the notes for user' do
        let(:notes_expected) { user_notes }

        before { get :index }

        it_behaves_like 'success request response'
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { user_notes.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it_behaves_like 'success request response'
      end

      context 'when fetching notes using note_type filter' do
        %w[review critique].each do |note_type|
          let(:notes_expected) { note_type == 'review' ? review_notes : critique_notes }

          before { get :index, params: { type: note_type } }

          it_behaves_like 'success request response'
        end
      end

      context 'when sorting notes by creation order' do
        %w[asc desc].each do |direction|
          let(:notes_expected) do
            sorted_notes = user_notes.sort_by(&:created_at)
            direction == 'asc' ? sorted_notes : sorted_notes.reverse
          end

          before { get :index, params: { order: direction } }

          it_behaves_like 'success request response'
        end
      end

      context 'when fetching notes using creation order and type filter' do
        let(:notes_expected) { review_notes.sort_by(&:created_at).reverse }

        before { get :index, params: { order: 'desc', type: 'review' } }

        it_behaves_like 'success request response'
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

      let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'success request response'
      end

      context 'when fetching a invalid note' do
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

        let(:message) { I18n.t('activerecord.success.create', { resource: I18n.t('activerecord.models.note')}) }

        it_behaves_like 'success post request with message'
      end

      context 'when required parameters are missing' do
        let(:missing_attributes) do
          {
            note: {
              title: nil,
              note_type: 'review',
              content: ''
            }
          }
        end

        before { post :create, params: missing_attributes }

        it_behaves_like 'bad request when a parameter is missing'
      end

      context 'when the note type is invalid' do
        let(:invalid_type_attributes) do
          {
            note: {
              title: Faker::Lorem.word,
              note_type: 'invalid_type',
              content: Faker::Lorem.sentence(word_count: 5)
            }
          }
        end

        before { post :create, params: invalid_type_attributes }
        
        let(:message) { I18n.t('activerecord.errors.note.invalid_attribute.note_type') }

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when the note content length exceeds the limit for reviews' do
        utility = Utility.new(type: ['NorthUtility', 'SouthUtility'].sample )

        let(:long_content_attributes) do
          {
            note: {
              title: 'Reseña',
              note_type: 'review',
              content: Faker::Lorem.sentence(word_count: 150),
              utility: utility
            }
          }
        end

        before { post :create, params: long_content_attributes }

        let(:message) { I18n.t('activerecord.errors.note.invalid_attribute.content_length', { note_type: 'review', threshold: utility.content_short_length })}

        it_behaves_like 'unprocessable entity with message'
      end
    end

    context 'when there is not a user logged in' do
      before { post :create, params: valid_attributes }

      it_behaves_like 'unauthorized'
    end
  end
end
