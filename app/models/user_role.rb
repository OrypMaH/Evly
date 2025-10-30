class UserRole < ApplicationRecord
    belongs_to :user
    belongs_to :role

    validates :user_id, uniqueness: { scope: :role_id }
    after_destroy :user_role_destroy_handler

  private

  def user_role_destroy_handler
    user.refresh_current_role
  end
end