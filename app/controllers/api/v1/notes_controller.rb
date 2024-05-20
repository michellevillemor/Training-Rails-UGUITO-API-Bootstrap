module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end
      
      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end
      
      private

      def notes
        current_user.notes
      end
      
      def filter_notes_by_type
        filtering_params[:note_type].present? ? Note.where(note_type: filtering_params[:note_type]) : notes
      end

      def sort_notes_by_order(notes)
        order = %w[asc desc].include?(filtering_params[:order]) ? filtering_params[:order] : 'asc'
        notes.order(created_at: order)
      end

      def paginated_notes(notes)
        page = params[:page] || 1 # page default
        page_size = params[:page_size] || 10 # page size default
        notes.page(page).per(page_size)
      end

      def notes_filtered
        notes = filter_notes_by_type
        notes = sort_notes_by_order notes
        paginated_notes notes
      end
      
      def filtering_params
        permitted = params.permit(:type, :order)
        { note_type: permitted[:type], order: permitted[:order] }
      end

      def show_note
        notes.find(params.require(:id))
      end
      
    end
  end
end
