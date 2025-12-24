class OfferedEventDepartment < ApplicationRecord
  belongs_to :event
  belongs_to :department
  belongs_to :proposed_by, class_name: 'User', foreign_key: 'proposed_by_user_id'
  
  validates :event, presence: true
  validates :department, presence: true
  validates :proposed_by, presence: true
  
  # Автоматически устанавливаем proposed_at при создании
  before_create :set_offered_data
  
  # Скоупы
  scope :for_department, ->(department) { where(department: department) }
  scope :for_event, ->(event) { where(event: event) }
  scope :pending, -> { where(proposed_at: 7.days.ago..Time.current) }
  scope :recent, -> { where('proposed_at >= ?', 7.days.ago) }
  
  # Преобразование в Approved
 def approve!(approved_by, participants_count = 1)
    # Преобразуем participants_count в integer
    participants_count = participants_count.to_i if participants_count.is_a?(String)
    participants_count = 1 if participants_count.blank? || participants_count < 1
    
    transaction do
      approved_ed = ApprovedEventDepartment.create!(
        event: event,
        department: department,
        approved_by: approved_by,
        participants_count: participants_count
      )
      destroy!
      approved_ed
    end
  end

  def reject!
    destroy
  end

  def status
    'offered'
  end
  
  private
  
  def set_offered_data
    self.proposed_at ||= Time.current
    self.proposed_by ||= current_user.id
  end
end