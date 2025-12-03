class ApprovedEventDepartment < ApplicationRecord
  belongs_to :event
  belongs_to :department
  belongs_to :approved_by, class_name: 'User', foreign_key: 'approved_by_user_id'
  
  validates :event, presence: true
  validates :department, presence: true
  validates :approved_by, presence: true
  validates :participants_count, numericality: { 
    greater_than: 0, 
    message: "должно быть положительным числом" 
  }
  
  # Автоматически устанавливаем approved_at при создании
  before_create :set_approved_data
  
  # Скоупы
  scope :for_department, ->(department) { where(department: department) }
  scope :for_event, ->(event) { where(event: event) }
  scope :active, -> { where('approved_at >= ?', 1.month.ago) }
  scope :with_participants, -> { where('participants_count > 0') }
  
  def status
    'approved'
  end

  def approve!(approved_by, participants_count = 1)
      self.approved_by = approved_by
      self.participants_count= participants_count
  end

  def reject!
    destroy
  end
  private
  
  def set_approved_data
    self.approved_at ||= Time.current
  end
end