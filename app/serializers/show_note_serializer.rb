class ShowNoteSerializer < ActiveModel::Serializer
    attributes :id, :title, :type, :word_count, :created_at, :content, :content_length
    belongs_to :user
end
