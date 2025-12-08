class Event < ApplicationRecord
    validates :title, presence: true, length: {minimum: 2}
    belongs_to :creator, class_name: 'User'
    has_many :offered_event_departments, dependent: :destroy
    has_many :approved_event_departments, dependent: :destroy

    def status_for(department)
        if approved_event_departments.for_department(department).exists?
            'approved'
        elsif offered_event_departments.for_department(department).exists?
            'offered'
        else
            nil
        end
    end

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
end
