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
        filtered_notes = apply_sorting filtered_notes if params[:order].present?

        filtered_notes
      end

      def apply_sorting(notes)
        notes.order(created_at: params[:order])
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
