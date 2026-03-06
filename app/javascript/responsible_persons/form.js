
const $ = window.$ || window.jQuery;
export function initResponsiblePersonCreate(){
    // Функция для обновления списка ролей на основе выбранного пользователя
    function updateRoles(userSelect, roleSelect) {
      const userId = userSelect.val();
      const roleDropdown = $(roleSelect);
      
      if (userId) {
        // AJAX запрос для получения ролей пользователя
        $.ajax({
          url: `/users/${userId}/roles`,
          method: 'GET',
          dataType: 'json',
          success: function(roles) {
            // Очищаем текущие опции
            roleDropdown.empty();
            roleDropdown.append('<option value="">Выберете должность</option>');
            
            // Добавляем новые опции
            roles.forEach(function(role) {
              roleDropdown.append(`<option value="${role.id}">${role.name}</option>`);
            });
            
            // Обновляем dropdown
            roleDropdown.dropdown('refresh');
          }
        });
      }
    }
    
    // Обработчик изменения выбора пользователя
    $(document).on('change', '.user-select', function() {
      const container = $(this).closest('.responsible-person-fields');
      const roleSelect = container.find('.role-select');
      updateRoles($(this), roleSelect);
    });
    
    // Обработчик удаления ответственного лица
    $(document).on('click', '.remove-responsible-person', function() {
      const container = $(this).closest('.responsible-person-fields');
      const destroyField = container.find('input[name$="[_destroy]"]');
      
      if (destroyField.length) {
        // Если запись уже существует в БД, помечаем на удаление
        destroyField.val('1');
        container.hide();
      } else {
        // Если это новая запись, просто удаляем из DOM
        container.remove();
      }
    });
}