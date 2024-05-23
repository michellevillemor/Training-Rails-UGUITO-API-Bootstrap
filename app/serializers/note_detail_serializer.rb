class NoteDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :word_count, :created_at, :content, :content_length
  belongs_to :user
end
