class Role < ApplicationRecord
    has_many :user_roles, dependent: :destroy
    has_many :users, through: :user_roles
    belongs_to :department

    validates :name, presence: true
    validates :name, uniqueness: { scope: :department_id }

    def full_name
        "#{name} (#{department.name})"
    end
end
