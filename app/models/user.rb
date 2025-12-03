class User < ApplicationRecord
  has_secure_password
  has_many :user_roles, 
        dependent: :destroy
  has_many :roles, 
        through: :user_roles
  belongs_to :current_role, 
        class_name: 'Role', 
        optional: true
  has_one :department, 
        through: :current_role,
        source: :department
  has_many :departments, 
        through: :roles,
         source: :department
  has_many :events, class_name: 'Event', foreign_key: 'creator_id', dependent: :nullify
  validate :current_role_must_be_assigned
  after_commit :refresh_current_role, on: [:create, :update]

  scope :with_roles_in_department, ->(department) {
  joins(:roles)
    .where(roles: { department: department })
    .distinct
    .includes(roles: :department)
}
  
  def full_name
    parts = [surname, name, patronymic].compact
    parts.any? ? parts.join(' ') : 'Не указано'
  end
  
  def current_role_name
    current_role&.name
  end

  def current_role=(role)
    if role.nil? || roles.include?(role)
      super(role)
    else
      errors.add(:current_role, "не назначена пользователю")
    end
  end

  def refresh_current_role
    return if current_role_id.blank?
    
    unless roles.exists?(id: current_role_id)
      new_current_role = roles.any? ? roles.first : nil
      update(current_role: new_current_role)
    end
  end
  private

  def current_role_must_be_assigned
    # Проверяем только если current_role_id изменился или установлен
    return unless current_role_id.present? && current_role_id_changed?
    
    # Проверяем что роль существует и назначена пользователю
    unless roles.exists?(id: current_role_id)
      errors.add(:current_role_id, "должна быть среди назначенных пользователю ролей")
    end
  end
  
  
end