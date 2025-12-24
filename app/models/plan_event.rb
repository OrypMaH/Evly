# app/models/plan_event.rb
class PlanEvent < ApplicationRecord
  belongs_to :plan
  belongs_to :event_department, class_name: 'ApprovedEventDepartment'
  
  validates :plan, presence: true
  validates :event_department, presence: true
  validates_uniqueness_of :event_department_id, scope: :plan_id
  
  # Предотвращаем добавление мероприятий из других подразделений
  validate :event_department_belongs_to_plan_department
  
  
  private
  
  def event_department_belongs_to_plan_department
    if plan && event_department && plan.department != event_department.department
      errors.add(:event_department, "мероприятие должно быть из того же подразделения что и план")
    end
  end
end