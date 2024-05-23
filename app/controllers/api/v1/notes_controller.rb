module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes, status: :ok, each_serializer: NoteSerializer
      rescue ArgumentError => e
        render_invalid_argument(e)
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
        apply_sorting filtered_notes
      end

      def apply_sorting(notes)
        # order = %w[asc desc].include?(params[:order]) ? params[:order] : 'asc'
        order = params[:order]
        notes.order(created_at: order)
      end

      def note
        Note.find(params.require(:id))
      end

      def filtering_params
        params.permit(:type, :title, :page, :page_size)
              .transform_keys { |key| key == 'type' ? 'note_type' : key }
      end
    end
  end
end
