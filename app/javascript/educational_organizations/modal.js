// app/javascript/packs/educational_organizations.js
const $ = window.$ || window.jQuery;
export function initEducationalOrganizationModal() {
  const modal = $('#new_educational_organization_modal');
  const form = $('#new_educational_organization_form');
  const select = $('#educational_organization_select');
  const newBtn = $('#new_educational_organization_btn');
  const cancelBtn = $('#cancel_modal_btn');
  const errorMessage = $('#modal_error_message');
  
  // Открытие модального окна
  newBtn.on('click', function() {
    modal.modal('show');
  });
  
  // Закрытие по кнопке Отмена
  cancelBtn.on('click', function() {
    modal.modal('hide');
  });
  
  // Отправка формы
  
  // Обработка успешного создания
  function handleSuccess(response) {
    modal.modal('hide');
    
    // Добавляем опцию в select
    const option = new Option(response.name, response.id, true, true);
    select.append(option);
    
    // Обновляем dropdown
    select.dropdown('refresh');
    select.dropdown('set selected', response.id);
    
    // Уведомление
    showToast('success', 'Организация создана');
    
    // Сброс формы
    resetForm();
  }
  
  // Обработка ошибок
  function handleError(xhr) {
    const errors = xhr.responseJSON.errors;
    let errorHtml = '<ul class="list">';
    
    for (let field in errors) {
      errors[field].forEach(error => {
        errorHtml += `<li>${field} ${error}</li>`;
      });
    }
    
    errorHtml += '</ul>';
    
    errorMessage
      .html(errorHtml)
      .show();
  }
  
  // Сброс формы
  function resetForm() {
    form[0].reset();
    errorMessage.hide();
    $('.ui.dropdown', modal).dropdown('clear');
  }
  
  // Сброс при закрытии
  modal.on('hidden', resetForm);
  
  // Показ toast уведомления
  function showToast(type, message) {
    $('body').toast({
      title: type === 'success' ? 'Успех' : 'Ошибка',
      message: message,
      class: type,
      showProgress: 'bottom',
      position: 'top right'
    });
  }
}