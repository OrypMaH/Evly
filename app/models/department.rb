class Department < ApplicationRecord
  belongs_to :parent, 
            class_name: 'Department', 
            optional: true
  has_many :children, 
          class_name: 'Department', 
          foreign_key: :parent_id, 
          dependent: :nullify
          
  has_many :roles, dependent: :destroy
  has_many :users, through: :roles
  has_many :directions, dependent: :destroy 

  has_many :offered_event_departments, dependent: :destroy
  has_many :approved_event_departments, dependent: :destroy
  has_many :offered_events, through: :offered_event_departments, class_name: 'Event'
  has_many :approved_events, through: :approved_event_departments, class_name: 'Event'

  has_many :plans, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validate :cannot_be_own_parent
  
  # Методы для иерархии
  def root?
    parent_id.nil?
  end
  
  def is_it_ancestor?(dep)
    current = self
    while current.parent.present?
      current = current.parent
      return true if current == dep
    end
    false
  end
  def ancestors
    return [] if root?
    parent.ancestors + [parent]
  end
  
  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end

  def tree
    ([self] + descendants)
  end
  
  def full_path
    if root?
      name
    else
      "#{parent.full_path} -> #{name}"
    end
  end
  def tree_to_root
    if parent
      parent.tree_to_root + [self]
    else
      [self]
    end
  end
  def full_tree
    (tree_to_root + tree).uniq
  end

  def self.root
    find_by(parent_id: nil)
  end

  def self.hierarchical
    # Возвращает подразделения в иерархическом порядке
    all.includes(:parent).sort_by { |dept| dept.ancestors.size }
  end

  def department
    return self
  end

  def current_plans
    plans.current.order(start_date: :desc)
  end
  
  # Активные планы (текущие)
  def active_plans
    plans.active.order(start_date: :desc)
  end

  def direction_tree
    return self.directions + self.parent&.direction_tree.to_a
  end

  private
  
  def cannot_be_own_parent
    if parent_id == id
      errors.add(:parent_id, "не может ссылаться на самого себя")
    end
  end
end
