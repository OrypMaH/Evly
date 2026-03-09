# app/models/responsible_person.rb
class ResponsiblePerson < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :role
  
  validates :user_id, presence: true
  validates :role_id, presence: true
  
  validates :user_id, uniqueness: { 
    scope: :event_id, 
    message: "уже назначен ответственным за это мероприятие" 
  }, unless: -> { event_id.nil? }
  
  validate :role_belongs_to_user
  
  scope :for_event, ->(event_id) { where(event_id: event_id) }
  scope :with_user, -> { includes(:user) }
  scope :with_role, -> { includes(:role) }
  
  def full_name
    user.full_name
  end
  
  def role_name
    role.name
  end

  def contact
    user.contact
  end
  
  def description
    "#{user.short_name} (#{role_name})"
  end
  
  private
  
  def role_belongs_to_user
    return if role_id.blank? || user_id.blank?
    
    unless user.roles.exists?(id: role_id)
      errors.add(:role_id, "не принадлежит выбранному пользователю")
    end
  end
end