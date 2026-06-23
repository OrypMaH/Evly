// app/javascript/events/form.js
const $ = window.$ || window.jQuery;

export function initEventForm() {
  const form = document.getElementById('eventForm');
  const startDateField = form?.querySelector('#event_start_date');
  const endDateField = form?.querySelector('#event_end_date');
  const startDatePicker = $('#startDatePicker');
  const endDatePicker = $('#endDatePicker');
  const eventLevelSelect = form?.querySelector('#event_event_level_id');
  const formatField = form?.querySelector('#event_format');
  const locationField = form?.querySelector('#event_location');
  
  if (!form) return;
  
  // Инициализация Semantic UI компонентов
  initSemanticUIComponents();
  
  // Инициализация календарей
  initDatePickers();
  
  // Валидация дат
  setupDateValidation();
  
  // Подсказки для полей
  setupFieldHints();
  
  // Инициализация формы Semantic UI
  initSemanticFormValidation();
}

function initSemanticUIComponents() {
  // Инициализация dropdown для выбора уровня
  $('.ui.dropdown').dropdown();
  
  // Инициализация календарей (базовая)
  if ($.fn.calendar) {
    $('.ui.calendar').calendar({
      type: 'datetime',
      firstDayOfWeek: 1,
      text: {
        days: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
        months: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'],
        monthsShort: ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'],
        today: 'Сегодня',
        now: 'Сейчас',
        am: 'AM',
        pm: 'PM'
      },
      formatter: {
        date: function(date, settings) {
          if (!date) return '';
          const day = date.getDate();
          const month = date.getMonth() + 1;
          const year = date.getFullYear();
          return `${day.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${year}`;
        },
        time: function(date, settings, forCalendar) {
          if (!date) return '';
          const hours = date.getHours();
          const minutes = date.getMinutes();
          return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
        }
      }
    });
  }
}

function initDatePickers() {
  const startDateField = document.querySelector('#event_start_date');
  const endDateField = document.querySelector('#event_end_date');
  
  if (startDateField && endDateField) {
    // Устанавливаем минимальную дату - сегодня
    const today = new Date().toISOString().split('T')[0];
    startDateField.min = today;
    
    // Обновляем минимальную дату окончания при изменении даты начала
    startDateField.addEventListener('change', function() {
      if (this.value) {
        endDateField.min = this.value;
        
        // Если текущая дата окончания стала раньше даты начала, показываем предупреждение
        if (endDateField.value && new Date(endDateField.value) < new Date(this.value)) {
          showDateWarning();
        }
      }
    });
    
    // Проверяем даты при изменении окончания
    endDateField.addEventListener('change', function() {
      if (startDateField.value && this.value) {
        validateDates(startDateField.value, this.value);
      }
    });
  }
}

function setupDateValidation() {
  const form = document.getElementById('eventForm');
  
  if (form) {
    form.addEventListener('submit', function(e) {
      const startDateField = this.querySelector('#event_start_date');
      const endDateField = this.querySelector('#event_end_date');
      
      if (startDateField.value && endDateField.value) {
        const startDate = new Date(startDateField.value);
        const endDate = new Date(endDateField.value);
        
        if (endDate < startDate) {
          e.preventDefault();
          showDateError('Дата окончания не может быть раньше даты начала!');
          endDateField.focus();
          return false;
        }
        
        // Проверка что мероприятие не слишком длинное (например, не более 30 дней)
        const diffTime = Math.abs(endDate - startDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays > 30) {
          if (!confirm(`Мероприятие длится ${diffDays} дней. Вы уверены, что это правильно?`)) {
            e.preventDefault();
            return false;
          }
        }
      }
      
      return true;
    });
  }
}

function validateDates(startDateStr, endDateStr) {
  const startDate = new Date(startDateStr);
  const endDate = new Date(endDateStr);
  
  if (endDate < startDate) {
    showDateWarning();
    return false;
  }
  
  hideDateWarning();
  return true;
}

function showDateWarning() {
  let warningDiv = document.getElementById('dateWarning');
  
  if (!warningDiv) {
    warningDiv = document.createElement('div');
    warningDiv.id = 'dateWarning';
    warningDiv.className = 'ui warning message';
    warningDiv.innerHTML = `
      <i class="warning icon"></i>
      <div class="content">
        <div class="header">Внимание!</div>
        <p>Дата окончания раньше даты начала. Система автоматически исправит это при сохранении.</p>
      </div>
    `;
    
    const dateFields = document.querySelector('.two.fields');
    if (dateFields) {
      dateFields.parentNode.insertBefore(warningDiv, dateFields.nextSibling);
    }
  }
  
  warningDiv.style.display = 'block';
}

function hideDateWarning() {
  const warningDiv = document.getElementById('dateWarning');
  if (warningDiv) {
    warningDiv.style.display = 'none';
  }
}

function showDateError(message) {
  // Используем Semantic UI toast или обычный alert
  if ($.toast) {
    $.toast({
      class: 'error',
      message: message,
      position: 'top center',
      showProgress: 'bottom'
    });
  } else {
    alert(message);
  }
}

function setupFieldHints() {
  // Подсказка для формата
  const formatField = document.querySelector('#event_format');
  if (formatField) {
    const formatHint = createHintElement('Например: очный, онлайн, гибридный, конференция, семинар, мастер-класс');
    formatField.parentNode.insertBefore(formatHint, formatField.nextSibling);
    
    formatField.addEventListener('focus', function() {
      formatHint.style.display = 'block';
    });
    
    formatField.addEventListener('blur', function() {
      formatHint.style.display = 'none';
    });
  }
  
  // Подсказка для места проведения
  const locationField = document.querySelector('#event_location');
  if (locationField) {
    const locationHint = createHintElement('Например: актовый зал, онлайн-платформа Zoom, аудитория 301, городской дворец культуры');
    locationField.parentNode.insertBefore(locationHint, locationField.nextSibling);
    
    locationField.addEventListener('focus', function() {
      locationHint.style.display = 'block';
    });
    
    locationField.addEventListener('blur', function() {
      locationHint.style.display = 'none';
    });
  }
}

function createHintElement(text) {
  const hint = document.createElement('div');
  hint.className = 'ui basic pointing label';
  hint.textContent = text;
  hint.style.display = 'none';
  hint.style.marginTop = '5px';
  return hint;
}

function initSemanticFormValidation() {
  // Инициализация валидации Semantic UI
  $('.ui.form.event-form').form({
    fields: {
      title: {
        identifier: 'event[title]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, введите название мероприятия'
        }, {
          type: 'minLength[2]',
          prompt: 'Название должно содержать минимум 2 символа'
        }]
      },
      start_date: {
        identifier: 'event[start_date]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, выберите дату начала'
        }]
      },
      end_date: {
        identifier: 'event[end_date]',
        rules: [{
          type: 'empty',
          prompt: 'Пожалуйста, выберите дату окончания'
        }]
      }
    },
    onSuccess: function(event) {
      // Можно добавить дополнительную логику перед отправкой
      return true;
    }
  });
}


function setDefaultDates() {
  const startDateField = document.querySelector('#event_start_date');
  const endDateField = document.querySelector('#event_end_date');
  
  if (startDateField && !startDateField.value) {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(10, 0, 0, 0);
    startDateField.value = tomorrow.toISOString().slice(0, 16);
  }
  
  if (endDateField && !endDateField.value && startDateField?.value) {
    const startDate = new Date(startDateField.value);
    const endDate = new Date(startDate);
    endDate.setHours(startDate.getHours() + 2);
    endDateField.value = endDate.toISOString().slice(0, 16);
  }
}
