class Event < ApplicationRecord
    validates :title, presence: true, length: {minimum: 2}
    belongs_to :creator, class_name: 'User'
    has_many :offered_event_departments, dependent: :destroy
    has_many :approved_event_departments, dependent: :destroy

    validates :start_date, presence: true
    validates :end_date, presence: true
    validate :validate_period_order

    def status_for(department)
        if approved_event_departments.for_department(department).exists?
            'approved'
        elsif offered_event_departments.for_department(department).exists?
            'offered'
        else
            nil
        end
    end
    
    scope :upcoming, -> { where('start_date > ?', Time.current) }
    scope :ongoing, -> { where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }
    scope :past, -> { where('end_date < ?', Time.current) }
    scope :in_period, ->(from, to) { where('start_date >= ? AND end_date <= ?', from, to) }

    scope :participating_by, ->(department) {
        joins(:approved_event_departments)
        .where(approved_event_departments: { department: department })
        .distinct
    }

    scope :offered_to, ->(department) {
        joins(:offered_event_departments)
        .where(offered_event_departments: { department: department })
        .distinct
    }
    def departments
        Department.where(id: offered_event_departments.select(:department_id))
                .or(Department.where(id: approved_event_departments.select(:department_id)))
    end
    def event_departments
        offered_event_departments + approved_event_departments
    end
    def people
        sum = 0
        approved_event_departments.each do |aed|
            sum+=aed.participants_count
        end
        return sum
    end
    def period_text

    end
    def ongoing?
        start_date <= Time.current && end_date >= Time.current
    end
    
    def upcoming?
        start_date > Time.current
    end
    
    def past?
        end_date < Time.current
    end
    
    private

    def normalize_dates
        return if start_date.blank? || end_date.blank?
        
        # Если start_date > end_date, меняем их местами
        if start_date > end_date
            self.start_date, self.end_date = end_date, start_date
        end
    end
    
    def validate_period_order
        return if start_date.blank? || end_date.blank?
        
        # После normalize_dates порядок всегда должен быть правильный
        if start_date > end_date
            errors.add(:base, "Дата начала не может быть позже даты окончания")
        end
    end
end
