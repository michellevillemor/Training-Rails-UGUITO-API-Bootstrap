module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      private

      def all_notes
        @notes ||= Note.all
      end

      def notes
        filtered_notes = all_notes.by_filter(filtering_params)
        paginated_notes = filtered_notes.paginated(params[:page], params[:page_size])
        paginated_notes = apply_sorting paginated_notes if params[:order].present?

        paginated_notes
      end

      def apply_sorting(notes)
        notes.order(created_at: params[:order])
      end

      def note
        Note.find(params.require(:id))
      end

      def filtering_params
        params.permit(:type, :title)
              .transform_keys { |key| key == 'type' ? 'note_type' : key }
      end
    end
  end
end
