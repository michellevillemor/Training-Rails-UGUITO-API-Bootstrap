module Api
	module V1
		class NotesController < ApplicationController
			
			def index
				render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
			end
			
			def show
				render json: show_book, status: :ok, serializer: ShowNoteSerializer
			end

			private

      def notes_filtered
        notes.where(filtering_params).page(params[:page]).per(params[:page_size])
      end

      def filtering_params
        params.permit(%i[type order])
      end
			
		end
	end
end
