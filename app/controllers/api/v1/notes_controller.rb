module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      def create
        if !validate_note_type(create_params[:note_type]) 
          handle_invalid_note_type
        else
          note = Note.new create_params
          handle_invalid_content_length if note.validate_content_length

          render_resource(Note.create!(create_params.merge(user: current_user)))
        end
      end

      private
>
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
        params.require(:note).permit(:title, :note_type, :content).merge(user_id: current_user.id)
      end

      def validate_note_type(note_type)
        Note.note_types.key?(note_type) && !Note.defined_enums.values.include?(create_params[:note_type])
      end

      def handle_invalid_note_type
        render json: {
          error: I18n.t('activerecord.errors.note.invalid_attribute.note_type'),
        }, status: :unprocessable_entity
      end

      def handle_invalid_content_length(e)
        binding.pry
        json_error = e.record.errors.errors.to_json
        parsed_error = JSON.parse(json_error)
        message = parsed_error.first['raw_type']

        render json: {
          error: message,
        }, status: :unprocessable_entity
      end
    end
  end
end
