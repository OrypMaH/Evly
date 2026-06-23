class Plan < ApplicationRecord
  belongs_to :department
  belongs_to :creator, class_name: 'User'
  
  has_many :plan_events, dependent: :destroy
  has_many :event_departments, through: :plan_events, source: :event_department
  
  validates :title, presence: true, length: { minimum: 3 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :department, presence: true
  validates :creator, presence: true
  
  validate :end_date_after_start_date
  
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :upcoming, -> { where('start_date > ?', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }
  scope :for_department, ->(department) { where(department: department) }
  
    def ongoing?
        start_date <= Time.current && end_date >= Time.current
    end
    def active?
      self.ongoing?
    end
    def upcoming?
        start_date > Time.current
    end
    
    def past?
        end_date < Time.current
    end
    def progress_percentage
      return 0 if start_date > Date.current
      return 100 if end_date < Date.current
      
      total_days = (end_date - start_date).to_i
      passed_days = (Date.current - start_date).to_i
      ((passed_days.to_f / total_days) * 100).round
    end
    
    def status_text
      if active?
        'Активный'
      elsif upcoming?
        'Предстоящий'
      else
        'Завершенный'
      end
    end
    
    def progress_percentage
      return 0 if start_date > Date.current
      return 100 if end_date < Date.current
      
      total_days = (end_date - start_date).to_i
      passed_days = (Date.current - start_date).to_i
      ((passed_days.to_f / total_days) * 100).round
    end
  private
  
  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, "должна быть после даты начала")
    end
  end
end