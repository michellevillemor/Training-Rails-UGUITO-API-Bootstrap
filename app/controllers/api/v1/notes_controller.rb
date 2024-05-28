module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        begin
          render json: notes, status: :ok, each_serializer: NoteSerializer
        rescue ActiveRecord::StatementInvalid
          render json: {
            error: I18n.t('activerecord.errors.messages.invalid_attribute')
          }, status: :unprocessable_entity
        rescue ArgumentError => e
          render json: {
            error: I18n.t('activerecord.errors.messages.invalid_attribute')
          }, status: :unprocessable_entity
        end
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      private

      def user_notes
        current_user.notes
      end

      def notes
        user_notes.by_filter(filtering_params).paginated(paginating_params[:page], paginating_params[:page_size]).with_order(ordering_params)
      end

      def note
        user_notes.find(params.require(:id))
      end

      def filtering_params
        params.permit(:note_type, :title).compact
      end

      def paginating_params
        params.permit(:page, :page_size).compact
      end

      def ordering_params
        params.permit[:order] || 'asc'
      end
    end
  end
end
