class RetrieveNotesWorker < BaseUserWorker
  private
  
  def initialize_variables(note_type)
    @note_type = note_type
  end
  
  def perform_args
    [@note_type]
  end
  
  def service
    :retrieve_notes
  end
  
  def attempt
    "retrieving notes with note_type: #{@note_type}"
  end
end
