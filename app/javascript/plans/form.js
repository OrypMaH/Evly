// app/javascript/plans/form.js
const $ = window.$ || window.jQuery;
export function initPlanCreate() {
  const startDateField = document.querySelector('#plan_start_date');
  const endDateField = document.querySelector('#plan_end_date');
  
  if (startDateField && endDateField) {
    // Обновляем минимальную дату окончания при изменении даты начала
    startDateField.addEventListener('change', function() {
      endDateField.min = this.value;
      
      // Если текущая дата окончания стала раньше даты начала, сбрасываем ее
      if (endDateField.value && endDateField.value < this.value) {
        endDateField.value = '';
      }
    });
    
    // Проверка при отправке формы
    const form = document.querySelector('.plan-form');
    if (form) {
      form.addEventListener('submit', function(e) {
        if (startDateField.value && endDateField.value) {
          const startDate = new Date(startDateField.value);
          const endDate = new Date(endDateField.value);
          
          if (endDate < startDate) {
            e.preventDefault();
            alert('Дата окончания не может быть раньше даты начала!');
            endDateField.focus();
          }
        }
      });
    }
  }
  
  // Инициализация Semantic UI для форм
  $('.ui.form').form({
    fields: {
      title: {
        identifier: 'plan[title]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, введите название плана'
        }, {
          type: 'minLength[3]',
          prompt: 'Название должно содержать минимум 3 символа'
        }]
      },
      start_date: {
        identifier: 'plan[start_date]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, выберите дату начала'
        }]
      },
      end_date: {
        identifier: 'plan[end_date]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, выберите дату окончания'
        }]
      }
    }
  });
}