class Permission < ApplicationRecord
  before_validation :generate_name, if: -> { name.blank? && action.present? && resource.present? && scope.present? }
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :action, :resource, :scope, presence: true
  validates :action, uniqueness: { scope: [:resource, :scope] }

  private

  def generate_name
    self.name = "#{action.humanize} #{resource.underscore.humanize} (#{scope.humanize})"
  end
end