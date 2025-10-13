class Faq < ApplicationRecord
  has_many :faq_answers, dependent: :destroy
  validates :question, presence: true, uniqueness: true
end
