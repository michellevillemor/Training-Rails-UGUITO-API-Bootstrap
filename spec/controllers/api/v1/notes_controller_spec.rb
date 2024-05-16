require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let!(:review_notes) { create_list(:note, 3, note_type: 'review') }
    let!(:critique_notes) { create_list(:note, 7, note_type: 'critique') }
    let(:notes) { review_notes + critique_notes }
    
    let!(:expected) do
      ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: IndexNoteSerializer).to_json
    end

    let!(:expected_desc_order) do
      ActiveModel::Serializer::CollectionSerializer.new(notes_expected.sort_by(&:created_at).reverse, serializer: IndexNoteSerializer).to_json
    end

    let!(:expected_asc_order) do
      ActiveModel::Serializer::CollectionSerializer.new(notes_expected.sort_by(&:created_at), serializer: IndexNoteSerializer).to_json
    end
        
    context 'when fetching all the notes' do
      let(:notes_expected) { notes }
      
      before { get :index }
      
      it 'responds with the expected notes json' do
        expect(response_body.to_json).to eq(expected)
      end
      
      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end
    
    context 'when fetching notes with page and page size params' do
      let(:page)            { 1 }
      let(:page_size)       { 2 }
      let(:notes_expected) { notes.first(2) }
      
      before { get :index, params: { page: page, page_size: page_size } }
      
      it 'responds with the expected notes' do
        expect(response_body.to_json).to eq(expected)
      end
      
      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end
    
    context 'when fetching notes using type filter' do
      let(:notes_expected) { review_notes }
      
      before { get :index, params: { type: 'review' } }
      
      it 'responds with expected notes' do
        expect(response_body.to_json).to eq(expected)
      end
      
      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching notes using asc creation order' do
      let(:notes_expected) { notes }

      before { get :index, params: { order: 'asc' } }
      
      it 'responds with expected notes in asc order' do
        expect(response_body.to_json).to eq(expected_asc_order)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching notes using desc creation order' do
      let(:notes_expected) { notes }

      before { get :index, params: { order: 'desc' } }

      it 'responds with expected notes in desc order' do
        expect(response_body.to_json).to eq(expected_desc_order)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching notes using creation order and type filter' do
      let(:notes_expected) { review_notes }

      before { get :index, params: { order: 'desc', type: 'review' } }
      
      it 'responds with expected notes in desc order and review type' do
        expect(response_body.to_json).to eq(expected_desc_order)
      end

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end  
  end

  describe ' GET #show' do
    context 'when fetching a valid note' do
      let(:note) { create(:note) }
      let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }

      before { get :show, params: { id: note.id } }
      
      it 'responds with the expected note json' do
        expect(response_body.to_json).to eq(expected)
      end
      
      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetching a invalid note' do
      before { get :show, params: { id: Faker::Number.number } }

      it 'responds with 404 status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
