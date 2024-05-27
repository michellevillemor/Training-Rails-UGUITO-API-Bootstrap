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

      def create
        note = current_user.notes.new creating_params
        note.save!
        render_resource(note)
      rescue ActiveRecord::RecordInvalid => e
        handle_record_invalid(e)
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

      def creating_params
        params.require(:note).permit(:title, :note_type, :content)
      end

      def handle_record_invalid(error)
        note_type_present = error.record.note_type.present?
        utility_present = error.record.utility.present?

        if note_type_present && utility_present
          render_missing_parameter(error,
                                   { note_type: error.record.note_type,
                                     threshold: error.record.utility.content_short_length })
        else
          render_missing_parameter(error)
        end
      end
    end
  end
end
