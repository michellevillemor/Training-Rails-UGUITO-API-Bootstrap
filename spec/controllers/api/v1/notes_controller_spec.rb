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
          context 'with Review note_type' do
            let(:notes_expected) { review_notes }
            let(:params) { { note_type: 'review' } }

            it_behaves_like 'successfull request array response'
          end

          context 'with Critique note_type' do
            let(:notes_expected) { critique_notes }
            let(:params) { { note_type: 'critique' } }

            it_behaves_like 'successfull request array response'
          end

          context 'with invalid note_type filter' do
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
              it_behaves_like 'successfull response array first element'
            end

            context 'when desc' do
              let(:notes_expected) { sorted_notes.reverse }
              let(:params) { { order: 'desc' } }

              it_behaves_like 'successfull request array response'
              it_behaves_like 'successfull response array first element'
            end

            context 'when invalid sort value' do
              let(:params) { { order: 'ascendent' } }

              let(:message) { I18n.t('activerecord.errors.messages.invalid_attribute') }

              it_behaves_like 'unprocessable entity with message'
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

  describe 'POST #create' do
    let(:base_create_params) do
      {
        note: {
          title: 'Reseña',
          note_type: 'review',
          content: Faker::Lorem.sentence(word_count: 5)
        }
      }
    end

    context 'when there is a user logged in' do
      subject { post :create, params: create_params }

      include_context 'with authenticated user'

      before { subject }

      context 'when the note is created successfully' do
        let(:create_params) { base_create_params }
        let(:message) { I18n.t('activerecord.success.create', { resource: I18n.t('activerecord.models.note') }) }

        it 'creates a new note and increases the note count by 1' do
          expect(user.notes.count).to eq(1)
        end

        it_behaves_like 'success post request with message'
      end

      context 'when required parameters are missing' do
        let(:missing_parameter) { [%i[content note_type title]].sample }
        let(:create_params) { base_create_params[:note].except(missing_parameter) }
        let(:message) { I18n.t('activerecord.errors.messages.missing_parameter') }

        it_behaves_like 'bad request when a parameter is missing'
      end

      context 'when the note type is invalid' do
        let(:create_params) { base_create_params.deep_merge(note: { note_type: 'invalid_type' }) }
        let(:message) { I18n.t('activerecord.errors.note.invalid_attribute.note_type') }

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when the note content length exceeds the limit for reviews' do
        let(:utility) { FactoryBot.create(%i[south_utility north_utility].sample) }
        let(:user) { FactoryBot.create(:user, utility_id: utility.id) }

        let(:create_params) { base_create_params.deep_merge(note: { content: Faker::Lorem.sentence(word_count: 150), user_id: user.id }) }
        let(:message) do
          I18n.t(
            'activerecord.errors.note.invalid_attribute.content_length',
            {
              note_type: 'review',
              threshold: utility.content_short_length
            }
          )
        end

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when the note content length has no limit threshold set in utility' do
        let(:utility) { FactoryBot.create(:utility) }
        let(:user) { FactoryBot.create(:user, utility_id: utility.id) }

        let(:create_params) { base_create_params.deep_merge(note: { content: Faker::Lorem.sentence(word_count: 150), user_id: user.id }) }
        let(:message) { I18n.t('activerecord.success.create', { resource: I18n.t('activerecord.models.note') }) }

        it 'creates a new note and increases the note count by 1' do
          expect(user.notes.count).to eq(1)
        end

        it_behaves_like 'success post request with message'
      end
    end

    context 'when there is not a user logged in' do
      let(:create_params) { base_create_params }

      before { post :create, params: create_params }

      it_behaves_like 'unauthorized'
    end
  end
end
