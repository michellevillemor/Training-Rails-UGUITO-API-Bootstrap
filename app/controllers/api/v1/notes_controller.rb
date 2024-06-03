module Api
  module V1
    class NotesController < ApplicationController
      rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
      rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

      before_action :authenticate_user!

      def index
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      def create
        return handle_invalid_note_type unless valid_note_type?(create_params[:note_type])
        render_resource(Note.create!(create_params.merge(user: current_user)))
      end

      private

      def user_notes
        current_user.notes
      end

      def notes
        user_notes.by_filter(filtering_params)
                  .paginated(paginating_params[:page], paginating_params[:page_size])
                  .with_order(ordering_params[:order] || 'asc')
      end

      def note
        user_notes.find(params.require(:id))
      end

      def filtering_params
        params.permit(:note_type).compact
      end

      def paginating_params
        params.permit(:page, :page_size).compact
      end

      def ordering_params
        params.permit(:order)
      end

      def create_params
        params.require(:note).require(%i[title note_type content])
        params.require(:note).permit(:title, :note_type, :content)
      end

      def valid_note_type?(note_type)
        Note.note_types.key?(note_type)
      end

      def handle_invalid_note_type
        render json: {
          error: I18n.t('activerecord.errors.note.invalid_attribute.note_type')
        }, status: :unprocessable_entity
      end

      def handle_invalid_record(e)
        render json: {
          error: e.record.errors.values.first
        }, status: :unprocessable_entity
      end

      def required_note_params
        {
          note: {
            title: true,
            content: true,
            note_type: true
          }
        }
      end
    end
  end
end
