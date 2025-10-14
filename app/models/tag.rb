class Tag < ApplicationRecord
  has_many :video_tags, dependent: :destroy
  has_many :videos, through: :video_tags
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
