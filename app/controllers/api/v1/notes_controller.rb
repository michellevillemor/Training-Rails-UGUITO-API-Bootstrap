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

      def create
        note = current_user.notes.new creating_params

        if creating_params.empty?
          missing_parameters_error
        elsif note.save
          resource_created note
        else
          validation_error note
        end
      end

      private

      def notes
        current_user.notes
      end

      def filter_notes_by_type
        note_type = filtering_params[:note_type]
        note_type.present? ? Note.where(note_type: filtering_params[:note_type]) : notes
      end

      def sort_notes_by_order(notes)
        order = %w[asc desc].include?(sortering_params[:order]) ? sortering_params[:order] : 'asc'
        notes.order(created_at: order)
      end

      def paginated_notes(notes)
        page = params[:page]
        page_size = params[:page_size]
        notes.page(page).per(page_size)
      end

      def notes_filtered
        notes = filter_notes_by_type
        notes = sort_notes_by_order notes
        paginated_notes notes
      end
      
      def show_note
        notes.find(params.require(:id))
      end

      def filtering_params
        permitted = params.permit(:type)
        { note_type: permitted[:type] }
      end

      def sortering_params
        params.permit(:order)
      end

      def creating_params
        params.require(:note).permit(:title, :note_type, :content)
      rescue ActionController::ParameterMissing
        {}
      end
    end
  end
end
