class Video < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_one_attached :thumbnail

  validates :title, presence: true
  validates :visibility, inclusion: { in: %w[public unlisted private] }
  validates :duration_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  after_commit :enqueue_processing, on: [ :create, :update ], if: -> { file.attached? }

  private

  def enqueue_processing
    VideoJob.perform_later(id)
  end
end
