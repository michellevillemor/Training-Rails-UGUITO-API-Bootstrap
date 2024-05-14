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
  validates :title, :content, :user, presence: true
  validate :validate_content_length

  enum note_type: { 'review' => 0, 'critique' => 1 }

  belongs_to :user
  has_one :utility, through: :user

  def validate_content_length
    return unless content_length != 'short' && note_type == 'review'

    error_message = I18n.t('activerecord.errors.note.content_length',
                           { note_type: note_type, threshold: utility.short_threshold,
                             utility_name: utility.name })
    errors.add(I18n.t('activerecord.attributes.note.content'), error_message)
  end

  def word_count
    content.split.length
  end

  def content_length
    return 'short' if word_count <= utility.short_threshold
    return 'medium' if word_count <= utility.medium_threshold
    'long'
  end
end
