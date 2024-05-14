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
  validates :user_id, :title, :content, :note_type, presence: true
  validate :validate_content_length

  enum note_type: { 'review' => 0, 'critique' => 1 }

  belongs_to :user
  has_one :utility, through: :user

  def validate_content_length
    return unless user_id == '' && content_length != 'short' && note_type == 'review'

    error_message = I18n.t('activerecord.errors.note.content_length', { note_type: note_type, threshold: utility.thresholds[:short], utility_name: utility.name})
    errors.add(error_message)
  end

  def word_count
    content.split.length
  end

  def content_length
    short_threshold = utility.thresholds[:short]
    medium_threshold = utility.thresholds[:medium]

    case word_count
    when 0..short_threshold
      'short'
    when short_threshold + 1..medium_threshold
      'medium'
    else 
      'long'
    end
  end
end
