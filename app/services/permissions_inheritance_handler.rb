class PermissionsInheritanceHandler
  def initialize(granter_user, target_permission, target_role = nil)
    @granter=granter_user
    @new_role=target_role
  end

  def can_grant?(perm)
    # Может дать право только если оно у него самого есть
    granter_has_permission?(perm)
  end

  def can_revoke?(perm)
    # Может забрать право только если оно у него самого есть
    granter_has_permission?(perm)
  end

  def handle_role_changes
    # Может изменять права роли только если имеет право управлять этой ролью
    return false unless @target_role
    
    engine = AbacEngine.new(@granter_user)
    engine.can?(:manage_permissions, @target_role)
  end

  private

  def granter_has_permission?(perm)
    granter_user.current_role.permissions.any? |permission|
    {
        perm == permission
    }
  end
end