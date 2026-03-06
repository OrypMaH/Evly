# app/models/event_level.rb
class EventLevel < ApplicationRecord
  # Связь с мероприятиями
  has_many :events, dependent: :nullify
  
  # Валидации
  validates :name, presence: true, uniqueness: true
  validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Скоупы для удобства
  scope :ordered, -> { order(:priority) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :above, ->(priority) { where('priority > ?', priority) }
  scope :below, ->(priority) { where('priority < ?', priority) }
  
  # Для отображения в выпадающих списках
  def display_name
    "#{name} (#{description})"
  end
  
  # Проверка можно ли удалить уровень
  def can_destroy?
    events.empty?
  end
end