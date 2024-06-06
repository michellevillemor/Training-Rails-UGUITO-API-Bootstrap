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
  scope :by_filter, ->(filters) { where(filters) }

  scope :paginated, ->(page, page_size) { page(page).per(page_size) }

  scope :with_order, ->(order) { order(created_at: order) }

  validates :user_id, :title, :content, :note_type, presence: true
  validate :validate_content_length, unless: lambda {
                                               user_id.blank? ||
                                                 content.blank? ||
                                                 !utility.content_thresholds?
                                             }

  enum note_type: { 'review' => 0, 'critique' => 1 }

  belongs_to :user
  has_one :utility, through: :user

  def validate_content_length
    return unless content_length != 'short' && note_type == 'review'

    error_message = I18n.t('activerecord.errors.note.invalid_attribute.content_length',
                           { note_type: note_type, threshold: utility.content_short_length })
    errors.add(:content_length, error_message)
  end

  def word_count
    content.split.length
  end

  def content_length
    return 'short' if utility.content_thresholds? && word_count <= utility.content_short_length
    return 'medium' if utility.content_thresholds? && word_count <= utility.content_medium_length
    'long' if utility.content_thresholds?
  end
end
