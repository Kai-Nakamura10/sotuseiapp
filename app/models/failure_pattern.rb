class FailurePattern < ApplicationRecord
    has_many :videos, dependent: :nullify
    validates :name, presence: true, uniqueness: true
end
