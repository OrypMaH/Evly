class Department < ApplicationRecord
  # Иерархические связи
  belongs_to :parent, 
            class_name: 'Department', 
            optional: true
  has_many :children, 
          class_name: 'Department', 
          foreign_key: :parent_id, 
          dependent: :nullify
  has_many :roles, 
          dependent: :destroy
  has_many :users, 
          through: :roles,
          source: :users
  validates :name, presence: true, 
            uniqueness: true
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
    children + children.flat_map(&:descendants)
  end

  def tree
    (ancestors + [self] + descendants)
  end
  
  def full_path
    if root?
      name
    else
      "#{parent.full_path} -> #{name}"
    end
  end
  
  def descendants_roles

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


  private
  
  def cannot_be_own_parent
    if parent_id == id
      errors.add(:parent_id, "не может ссылаться на самого себя")
    end
  end
end
