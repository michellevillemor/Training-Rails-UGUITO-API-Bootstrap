class NoteSerializer < ActiveModel::Serializer
  EXPECTED_KEYS = %w[id title note_type content_length].freeze

  attributes :id, :title, :note_type, :content_length
end
