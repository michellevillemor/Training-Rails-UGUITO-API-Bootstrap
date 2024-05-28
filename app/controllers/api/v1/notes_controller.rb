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

      def notes
        notes = Note.by_filter(filtering_params).paginated(paginating_params).with_order(ordering_params)
      end

      def note
        Note.find(params.require(:id))
      end

      def filtering_params
        params.permit(:type, :title).compact
      end

      def paginating_params
        params.permit(:page, :page_size).compact
      end

      def ordering_params
        params.permit[:order].compact
      end
    end
  end
end
