class Video < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_one_attached :thumbnail

  validates :title, presence: true
  validates :visibility, inclusion: { in: %w[public unlisted private] }
  after_commit :enqueue_processing, on: [ :create, :update ], if: -> { file.attached? }

  private

  def enqueue_processing
    VideoJob.perform_later(id)
  end
end
