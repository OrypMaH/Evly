class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :action, :resource, :scope, presence: true
  validates :action, uniqueness: { scope: [:resource, :scope] }
end