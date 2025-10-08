class Timeline < ApplicationRecord
  belongs_to :video

  KINDS = %w[question bestselect].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :start_seconds, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :end_seconds, numericality: { greater_than_or_equal_to: :start_seconds }, allow_nil: true
  validates :title, presence: true, if: -> { body.present? }

  def to_s
    title.presence || "#{kind} at #{start_seconds}s"
  end
end
