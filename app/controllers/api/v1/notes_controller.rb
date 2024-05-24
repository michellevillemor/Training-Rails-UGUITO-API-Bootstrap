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

      private

      def user_notes
        current_user.notes
      end

      def notes
        notes = user_notes.by_filter(filtering_params.compact).paginated(paginating_params)
        ordering_params? ? apply_sorting(notes) : notes
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

      def paginating_params
        params.permit(:page, :page_size)
      end

      def ordering_params?
        params[:order].present?
      end
    end
  end
end
