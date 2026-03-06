class Event < ApplicationRecord
    validates :title, presence: true, length: {minimum: 2}
    validates :start_date, presence: true
    validates :end_date, presence: true

    validate :validate_period_order
    validate :at_least_one_responsible_person, on: :update

    belongs_to :creator, class_name: 'User'
    belongs_to :level, class_name: 'EventLevel', foreign_key: 'event_level_id'
    belongs_to :direction, optional: false
    belongs_to :educational_organization, optional: false
    
    has_many :offered_event_departments, dependent: :destroy
    has_many :approved_event_departments, dependent: :destroy
    has_many :responsible_people, dependent: :destroy
    
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
    
    scope :by_level_priority, -> { joins(:event_level).order('event_levels.priority') }
    
    accepts_nested_attributes_for :responsible_people, 
                                allow_destroy: true,
                                reject_if: :all_blank
                                

    def status_for(department)
        if approved_event_departments.for_department(department).exists?
            'approved'
        elsif offered_event_departments.for_department(department).exists?
            'offered'
        else
            nil
        end
    end
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
        
        if start_date > end_date
            errors.add(:base, "Дата начала не может быть позже даты окончания")
        end
    end

    def at_least_one_responsible_person
        if responsible_people.reject(&:marked_for_destruction?).empty?
        errors.add(:base, "Должно быть хотя бы одно ответственное лицо")
        end
    end
end
