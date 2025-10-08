class Choice < ApplicationRecord
  belongs_to :question
  validates :body, presence: true
  validates :is_correct, inclusion: { in: [true, false] }
end
