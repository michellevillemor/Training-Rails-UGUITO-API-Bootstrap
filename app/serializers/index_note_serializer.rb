class IndexNoteSerializer < ActiveModel::Serializer
    attributes :id, :title, :type, :content_length
end
