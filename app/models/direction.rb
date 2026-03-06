class Direction < ApplicationRecord
  has_many :events
  belongs_to :department

  validates :name, presence: true
  validates :name, uniqueness: { scope: :department_id }
  
end
