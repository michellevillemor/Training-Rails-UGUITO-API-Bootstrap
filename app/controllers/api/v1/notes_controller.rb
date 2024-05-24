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
        note = current_user.notes.new creating_params

        if note.save
          resource_created note
        else
          handle_note_errors note
        end
      rescue ArgumentError => e
        handle_invalid_argument(e)
      end

      private

      def user_notes
        current_user.notes
      end

      def notes
        filtered_notes = user_notes.by_filter(filtering_params)
        paginated_notes = filtered_notes.paginated(params[:page], params[:page_size])
        paginated_notes = apply_sorting paginated_notes if params[:order].present?

        paginated_notes
      end

      def apply_sorting(notes)
        notes.order(created_at: params[:order])
      end

      def note
        user_notes.find(params.require(:id))
      end

      def filtering_params
        params.permit(:type, :title)
              .transform_keys { |key| key == 'type' ? 'note_type' : key }
      end

      def creating_params
        params.require(:note).permit(:title, :note_type, :content)
      end

      def handle_note_errors(note)
        if note.errors.details[:title].any? { |e| e[:error] == :blank }
          missing_parameters_error
        else
          validation_error(note)
        end
      end
    end
  end
end
