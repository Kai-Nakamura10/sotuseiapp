class Tactic < ApplicationRecord
  has_many :video_tactics, dependent: :destroy
  has_many :videos, through: :video_tactics
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  serialize :steps, JSON
end
