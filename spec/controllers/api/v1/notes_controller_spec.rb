require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let!(:review_notes) { create_list(:note, 3, note_type: 'review') }
    let!(:critique_notes) { create_list(:note, 7, note_type: 'critique') }
    let(:notes) { review_notes + critique_notes }

    let(:expected) do
      ActiveModel::Serializer::CollectionSerializer.new(notes_expected, serializer: IndexNoteSerializer).to_json
    end

    context 'when fetching all the notes' do
      let(:notes_expected) { notes }

      before { get :index }

      it_behaves_like 'success request response'
    end

    context 'when fetching notes with page and page size params' do
      let(:page)            { 1 }
      let(:page_size)       { 2 }
      let(:notes_expected) { notes.first(2) }

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
          sorted_notes = notes.sort_by(&:created_at)
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

  describe ' GET #show' do
    context 'when fetching a valid note' do
      let(:note) { create(:note) }
      let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }

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
end
