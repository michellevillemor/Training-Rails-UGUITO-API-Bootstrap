# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :text             not null
#  note_type  :integer          default("review"), not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  scope :by_filter, lambda { |filters|
    notes = all
    compacted_filter = filters.compact
    compacted_filter.each do |filter_field, filter_value|
      notes = notes.where(filter_field => filter_value)
    end

    notes
  }

  scope :paginated, lambda { |page, page_size|
    notes = all
    notes = notes.page(page).per(page_size)

    notes
  }

  validates :user_id, :title, :content, :note_type, presence: true
  validate :validate_content_length, unless: -> { user_id.blank? || content.blank? }

  enum note_type: { 'review' => 0, 'critique' => 1 }

  belongs_to :user
  has_one :utility, through: :user

  def validate_content_length
    return unless content_length != 'short' && note_type == 'review'

    error_message = I18n.t('activerecord.errors.note.invalid_attribute.content_length',
                           { note_type: note_type, threshold: utility.content_short_length,
                             utility_name: utility.name })
    errors.add(I18n.t('activerecord.attributes.note.content'), error_message)
  end

  def word_count
    content.split.length
  end

  def content_length
    return 'short' if word_count <= utility.content_short_length
    return 'medium' if word_count <= utility.content_medium_length
    'long'
  end
end
