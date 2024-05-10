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

  enum note_type: { review: 0, critique: 1 }
  
  belongs_to :user
  has_one :utility, through: :user


  def word_count
    content.split.length
  end

end
