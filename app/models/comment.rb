class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :video
  belongs_to :timeline
  validates :body, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  default_scope { order(created_at: :asc) }
  def to_s
    body.truncate(30)
  end
  def formatted_created_at
    created_at.strftime("%Y-%m-%d %H:%M")
  end
end
