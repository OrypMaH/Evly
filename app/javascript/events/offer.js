const $ = window.$ || window.jQuery;
export function initOfferParticipationModal() {
  const offerButtons = document.querySelectorAll('.offer-button');
  const offerModal = document.getElementById('offerParticipationModal');
  const form = document.getElementById('offerParticipationForm');
  const departmentsList = document.getElementById('departmentsList');
  
  if (!offerModal || !form || !departmentsList) return;
  
  // Инициализируем Semantic UI модальное окно
  $(offerModal).modal({
    closable: true,
    onShow: function() {
      resetOfferForm();
    },
    onDeny: function() {
      resetOfferForm();
    }
  });
  
  offerButtons.forEach(button => {
    button.addEventListener('click', function() {
      const eventId = this.getAttribute('data-event-id');
      const eventTitle = this.getAttribute('data-event-title');
      
      // Обновляем заголовок и action формы
      document.getElementById('offerModalHeader').textContent = 
        `Предложение участия: ${eventTitle}`;
      form.action = `/events/${eventId}/offer`;
      document.getElementById('modalEventId').value = eventId;
      
      // Загружаем доступные подразделения
      loadAvailableDepartments(eventId, departmentsList);
      
      // Показываем модальное окно
      $(offerModal).modal('show');
    });
  });
  
  // Загрузка доступных подразделений при открытии модалки
  function loadAvailableDepartments(eventId, container) {
    container.innerHTML = '<div class="ui active centered inline loader">Загрузка подразделений...</div>';
    
    fetch(`/events/${eventId}/available_departments`)
      .then(response => response.json())
      .then(data => {
        if (data.departments && data.departments.length > 0) {
          displayDepartmentsList(data.departments, container);
        } else {
          container.innerHTML = '<div class="ui warning message">Нет доступных подразделений для предложения</div>';
          document.getElementById('offerSubmitBtn').disabled = true;
        }
      })
      .catch(error => {
        console.error('Error loading departments:', error);
        container.innerHTML = '<div class="ui error message">Ошибка загрузки подразделений</div>';
        document.getElementById('offerSubmitBtn').disabled = true;
      });
  }
  
  // Отображение списка подразделений
  function displayDepartmentsList(departments, container) {
    container.innerHTML = '';
    
    departments.forEach(dept => {
      const listItem = document.createElement('div');
      listItem.className = 'item';
      listItem.innerHTML = `
        <div class="ui checkbox">
          <input type="checkbox" name="department_ids[]" value="${dept.id}" id="dept_${dept.id}">
          <label for="dept_${dept.id}">
            <div class="content">
              <div class="header">${dept.name}</div>
              ${dept.description ? `<div class="description">${dept.description}</div>` : ''}
            </div>
          </label>
        </div>
      `;
      
      container.appendChild(listItem);
    });
    
    // Инициализируем чекбоксы Semantic UI
    $(container).find('.ui.checkbox').checkbox({
      onChecked: updateSelectedCount,
      onUnchecked: updateSelectedCount
    });
    
    // Вызываем для инициализации состояния
    updateSelectedCount();
  }
  
  // Обновление счетчика выбранных подразделений
  function updateSelectedCount() {
    const selectedCount = document.querySelectorAll('input[name="department_ids[]"]:checked').length;
    const submitBtn = document.getElementById('offerSubmitBtn');
    
    document.getElementById('selectedDepartmentsCount').textContent = selectedCount;
    submitBtn.disabled = selectedCount === 0;
  }
  
  // Сброс формы
  function resetOfferForm() {
    document.getElementById('selectedDepartmentsCount').textContent = '0';
    document.getElementById('offerSubmitBtn').disabled = true;
    if (departmentsList) {
      departmentsList.innerHTML = '<div class="ui active centered inline loader">Загрузка подразделений...</div>';
    }
  }
  
  // Оставляем обычную отправку формы - она сама сделает redirect
  form.addEventListener('submit', function() {
    // Даем время на отправку и закрываем модалку
    setTimeout(() => {
      $(offerModal).modal('hide');
    }, 100);
  });
}