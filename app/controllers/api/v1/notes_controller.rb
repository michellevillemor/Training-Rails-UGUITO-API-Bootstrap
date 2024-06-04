module Api
  module V1
    class NotesController < ApplicationController
      rescue_from ActiveRecord::StatementInvalid, with: :handle_invalid_attribute
      rescue_from ArgumentError, with: :handle_invalid_attribute

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
        user_notes.by_filter(filtering_params)
                  .paginated(paginating_params[:page], paginating_params[:page_size])
                  .with_order(ordering_params[:order] || 'asc')
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
        params.permit(:order)
      end

      def handle_invalid_attribute(e)
        render json: {
          error: I18n.t('activerecord.errors.messages.invalid_attribute'),
          details: e.message
        }, status: :unprocessable_entity
      end
    end
  end
end
