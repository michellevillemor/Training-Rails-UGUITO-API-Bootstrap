module UtilityService
  module North
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        {
          autor: params['author']
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
