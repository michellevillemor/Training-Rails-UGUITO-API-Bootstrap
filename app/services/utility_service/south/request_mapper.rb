module UtilityService
  module South
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        {
          Autor: params['author']
        }
      end

      def retrieve_notes(params)
        {
          note_type: params['note_type']
        }
      end
    end
  end
end
