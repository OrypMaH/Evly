class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :department

  validates :name, presence: true
  validates :name, uniqueness: { scope: :department_id }

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :responsible_people


  def full_name
      "#{name} (#{department.name})"
  end
  def is_admin?
    return id==1
  end
  private
  def update_responsible_people_roles
    responsible_people = ResponsiblePerson.where(user_id: user_id, role_id: role_id)
    
    if responsible_people.any?
      if user.current_role_id.present?
        responsible_people.update_all(role_id: user.current_role_id)
      else
        responsible_people.destroy
      end
    end
  end
end
