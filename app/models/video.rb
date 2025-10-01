class Video < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_one_attached :thumbnail

  validates :title, presence: true
  validates :visibility, inclusion: { in: %w[public unlisted private] }
end
