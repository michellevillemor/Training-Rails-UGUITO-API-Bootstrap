module Api
  module V1
    class NotesController < ApplicationController
      rescue_from ActiveRecord::RecordInvalid, with: :handle_missing_parameters
      rescue_from ActiveRecord::StatementInvalid, with: :handle_invalid_parameters
      rescue_from ArgumentError, with: :handle_invalid_enums

      before_action :authenticate_user!

      def index
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      def create
        render_resource(Note.create!(create_params.merge(user: current_user)))
      end

      private

      def user_notes
        current_user.notes
      end

      def notes
        user_notes.by_filter(filtering_params)
                  .paginated(paginating_params[:page], paginating_params[:page_size])
                  .with_order(ordering_params)
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

      def create_params
        params.require(:note).permit(:title, :note_type, :content)
      end

      def handle_invalid_parameters(e)
        render_invalid_parameters(e)
      end

      def handle_missing_parameters(e)
        error_fields = e.record.errors.messages.keys
        render_missing_parameters(e, error_fields)
      end

      def handle_invalid_enums(e)
        error_fields = identify_invalid_enum(Note, create_params)
        render_invalid_enums(e, error_fields)
      end

      def identify_invalid_enum(klass, params)
        invalid_fields = []

        params.each do |key, value|
          klass_enums = klass.defined_enums

          invalid_fields << key if klass_enums.key?(key.to_s) && !klass_enums[key.to_s].key?(value)
        end

        invalid_fields
      end
    end
  end
end
