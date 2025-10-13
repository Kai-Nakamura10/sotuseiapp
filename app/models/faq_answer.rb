class FaqAnswer < ApplicationRecord
  belongs_to :faq_question
  validates :content, presence: true
end
