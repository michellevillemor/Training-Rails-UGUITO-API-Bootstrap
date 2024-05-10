require 'pry'
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

  enum note_type: { review: 0, critique: 1 }

  belongs_to :user
  has_one :utility, through: :user

  SHORT_THRESHOLD = { 'North Utility' => 50, 'South Utility' => 60 }.freeze
  MEDIUM_THRESHOLD = { 'North Utility' => 100, 'South Utility' => 120 }.freeze

  def validate_content_length
    return unless content_length != 'short' && note_type == 'review'

    note_type_translation = I18n.t("activerecord.models.note.note_type.#{note_type}")
    content_length_translation = I18n.t('activerecord.errors.note.content_length')

    error_message = I18n.interpolate('%<note_type>s %<content_length>s %<threshold>s %<words>s',
                                     note_type: note_type_translation,
                                     content_length: content_length_translation,
                                     threshold: SHORT_THRESHOLD[utility.name],
                                     words: I18n.t('words'))

    errors.add(:content, error_message)
  end

  def word_count
    content.split.length
  end

  def content_length
    short_threshold = SHORT_THRESHOLD[utility.name]
    medium_threshold = MEDIUM_THRESHOLD[utility.name]

    case word_count
    when 0..short_threshold
      'short'
    when short_threshold + 1..medium_threshold
      'medium'
    else 'long'
    end
  end
end
