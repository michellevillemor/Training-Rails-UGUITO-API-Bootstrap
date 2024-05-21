require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do  
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:review_notes) { create_list(:note, 3, note_type: 'review', user: user) }
      let!(:critique_notes) { create_list(:note, 7, note_type: 'critique', user: user) }
      let(:user_notes) { review_notes + critique_notes }

      let!(:expected) do
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
        ['review','critique'].each do |note_type|
          let(:notes_expected) { note_type == 'review' ? review_notes : critique_notes }
  
          before { get :index, params: { type: note_type } }
  
          it_behaves_like 'success request response'
        end
      end
  
      context 'when fetching notes sorting by creation order' do
        ['asc','desc'].each do |direction|
          let(:notes_expected) { direction == 'asc' ? notes.sort_by(&:created_at) : notes.sort_by(&:created_at).reverse }
  
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

        it 'responds with the success message' do
          expect(response_body['message']).to eq(I18n.t('activerecord.success.create', { resource: I18n.t('activerecord.models.note')}))
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when required parameters are missing' do
        let(:missing_attributes) do
          {
            note: {
              title: '',
              note_type: 'review',
              content: ''
            }
          }
        end

        before { post :create, params: missing_attributes }

        it 'responds with error message' do
          response_body['errors'].each do | error |
            expect(error['detail']).to eq(I18n.t('activerecord.errors.messages.invalid_attribute', { attribute: error['attribute'] }))
          end
        end

        it 'responds with 422 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
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

        it 'responds with error message' do
          expect(response_body['error']).to eq('Note type is not included in the list')
        end

        it 'responds with 422 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the note content length exceeds the limit for reviews' do
        let(:long_content_attributes) do
          {
            note: {
              title: 'Reseña',
              note_type: 'review',
              content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' * 20
            }
          }
        end

        before { post :create, params: long_content_attributes }

        it 'responds with error message' do
          expect(response_body['error']).to eq('Una reseña no puede superar las 50 palabras.')
        end

        it 'responds with 422 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when there is not a user logged in' do
      before { post :create, params: valid_attributes }

      it_behaves_like 'unauthorized'
    end
  end
end
