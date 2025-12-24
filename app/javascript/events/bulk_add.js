// app/javascript/events/bulk_add.js
const $ = window.$ || window.jQuery;

export function initBulkAdd() {
  const bulkAddButton = document.getElementById('bulkAddButton');
  const selectAllCheckbox = document.getElementById('selectAllCheckbox');
  const eventCheckboxes = document.querySelectorAll('.event-checkbox');
  const clearSelectionButton = document.getElementById('clearSelectionButton');
  const bulkAddModal = document.getElementById('bulkAddToPlanModal');
  const planSelect = document.getElementById('planSelect');
  const confirmBulkAddButton = document.getElementById('confirmBulkAdd');
  const selectedEventsCountSpan = document.getElementById('selectedEventsCount');
  const selectedCountSpan = document.getElementById('selectedCount');
  const selectedCountLabel = document.getElementById('selectedCountLabel');
  
  // Инициализация
  if (bulkAddButton) {
    setupEventHandlers();
  }
  
  function setupEventHandlers() {
    // Обработчик "Выбрать все"
    if (selectAllCheckbox) {
      selectAllCheckbox.addEventListener('change', function() {
        const isChecked = this.checked;
        eventCheckboxes.forEach(checkbox => {
          checkbox.checked = isChecked;
        });
        updateSelectionCount();
      });
    }
    
    // Обработчики для отдельных чекбоксов
    eventCheckboxes.forEach(checkbox => {
      checkbox.addEventListener('change', updateSelectionCount);
    });
    
    // Очистка выбора
    if (clearSelectionButton) {
      clearSelectionButton.addEventListener('click', function() {
        eventCheckboxes.forEach(checkbox => checkbox.checked = false);
        if (selectAllCheckbox) selectAllCheckbox.checked = false;
        updateSelectionCount();
      });
    }
    
    // Открытие модального окна для добавления
    bulkAddButton.addEventListener('click', function() {
      const selectedEventDepartments = getSelectedEventDepartmentsData();
      if (selectedEventDepartments.length > 0) {
        openBulkAddModal(selectedEventDepartments);
      }
    });
    
    // Загрузка планов при открытии модального окна
    if (bulkAddModal) {
      $(bulkAddModal).modal({
        onShow: function() {
          const selectedData = bulkAddModal.getAttribute('data-selected-data');
          if (selectedData) {
            loadPlansForEventDepartments(JSON.parse(selectedData));
          }
        },
        onHide: function() {
          resetModal();
        }
      });
    }
    
    // Обработчик выбора плана
    if (planSelect) {
      planSelect.addEventListener('change', function() {
        updatePlanInfo(this.value);
        updateConfirmButton();
      });
    }
    
    // Инициализация Semantic UI
    $('.ui.checkbox').checkbox();
    $('.ui.dropdown').dropdown();
  }
  
  function updateSelectionCount() {
    const selectedCount = getSelectedEventDepartmentsData().length;
    const hasSelection = selectedCount > 0;
    
    // Обновляем счетчик на странице
    if (selectedCountSpan) {
      selectedCountSpan.textContent = selectedCount;
    }
    
    // Показываем/скрываем счетчик
    if (selectedCountLabel) {
      selectedCountLabel.style.display = hasSelection ? 'inline-block' : 'none';
    }
    
    // Включаем/выключаем кнопку
    if (bulkAddButton) {
      bulkAddButton.disabled = !hasSelection;
    }
    
    // Обновляем состояние "Выбрать все"
    if (selectAllCheckbox) {
      const allChecked = eventCheckboxes.length > 0 && 
                         selectedCount === eventCheckboxes.length;
      selectAllCheckbox.checked = allChecked;
      $(selectAllCheckbox).checkbox('set checked', allChecked);
    }
  }
  
  function getSelectedEventDepartmentsData() {
    const selected = [];
    document.querySelectorAll('.event-checkbox:checked').forEach(checkbox => {
      selected.push({
        id: parseInt(checkbox.value),
        title: checkbox.getAttribute('data-event-title'),
        start_date: checkbox.getAttribute('data-event-start-date'),
        department_id: parseInt(checkbox.getAttribute('data-event-department-id'))
      });
    });
    return selected;
  }
  
  function getSelectedEventTitles(selectedData) {
    return selectedData.map(item => item.title);
  }
  
  function openBulkAddModal(selectedData) {
    // Сохраняем выбранные данные в модальном окне
    bulkAddModal.setAttribute('data-selected-data', JSON.stringify(selectedData));
    
    // Обновляем счетчик в модальном окне
    selectedEventsCountSpan.textContent = selectedData.length;
    
    // Показываем список выбранных мероприятий
    const selectedEventsList = document.getElementById('selectedEventsList');
    if (selectedEventsList) {
      selectedEventsList.innerHTML = '';
      getSelectedEventTitles(selectedData).forEach(title => {
        const item = document.createElement('div');
        item.className = 'item';
        item.innerHTML = `<i class="calendar icon"></i><div class="content">${title}</div>`;
        selectedEventsList.appendChild(item);
      });
      selectedEventsList.style.display = selectedData.length > 0 ? 'block' : 'none';
    }
    
    // Показываем модальное окно
    $(bulkAddModal).modal('show');
  }
  
  function loadPlansForEventDepartments(selectedData) {
    // Собираем ID мероприятий для отправки
    const eventDepartmentIds = selectedData.map(item => item.id);
    
    // Рассчитываем период мероприятий
    const startDates = selectedData.map(item => new Date(item.start_date));
    const minStartDate = startDates.length > 0 ? 
      new Date(Math.min(...startDates)).toISOString().split('T')[0] : null;
    const maxStartDate = startDates.length > 0 ? 
      new Date(Math.max(...startDates)).toISOString().split('T')[0] : null;
    
    fetch('/plans/available_for_events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        event_department_ids: eventDepartmentIds,
        min_start_date: minStartDate,
        max_start_date: maxStartDate
      })
    })
      .then(response => response.json())
      .then(data => {
        updatePlanSelect(data.plans);
      })
      .catch(error => {
        console.error('Error loading plans:', error);
        showError('Ошибка загрузки планов');
      });
  }
  
  function updatePlanSelect(plans) {
    // Очищаем список
    planSelect.innerHTML = '<option value="">Выберите план...</option>';
    
    // Добавляем планы
    if (plans && plans.length > 0) {
      plans.forEach(plan => {
        const option = document.createElement('option');
        option.value = plan.id;
        option.textContent = `${plan.title} (${plan.start_date} - ${plan.end_date})`;
        option.setAttribute('data-plan-info', JSON.stringify(plan));
        planSelect.appendChild(option);
      });
      
    } else {
      const option = document.createElement('option');
      option.value = "";
      option.textContent = "Нет подходящих планов";
      option.disabled = true;
      planSelect.appendChild(option);
    }
    
    // Реинициализируем dropdown
    $(planSelect).dropdown('refresh');
    updateConfirmButton();
  }
  
  function updatePlanInfo(planId) {
    const planInfo = document.getElementById('planInfo');
    const planTitle = document.getElementById('planTitle');
    const planPeriod = document.getElementById('planPeriod');
    const planEventsCount = document.getElementById('planEventsCount');
    
    if (planId) {
      const selectedOption = planSelect.querySelector(`option[value="${planId}"]`);
      if (selectedOption && selectedOption.getAttribute('data-plan-info')) {
        const plan = JSON.parse(selectedOption.getAttribute('data-plan-info'));
        
        planTitle.textContent = plan.title;
        planPeriod.textContent = `${plan.start_date} - ${plan.end_date}`;
        planEventsCount.textContent = plan.events_count || 0;
        planInfo.style.display = 'block';
      } else {
        planInfo.style.display = 'none';
      }
    } else {
      planInfo.style.display = 'none';
    }
  }
  
  function updateConfirmButton() {
    const selectedPlanId = planSelect.value;
    const hasPlans = planSelect.options.length > 1; // больше чем один option (первый пустой)
    confirmBulkAddButton.disabled = !selectedPlanId || !hasPlans;
  }
  
  function resetModal() {
    planSelect.value = '';
    document.getElementById('planInfo').style.display = 'none';
    document.getElementById('periodInfo').style.display = 'none';
    confirmBulkAddButton.disabled = true;
  }
  
  function showError(message) {
    const errorDiv = document.getElementById('modalError');
    if (errorDiv) {
      errorDiv.innerHTML = `<div class="ui error message">${message}</div>`;
      errorDiv.style.display = 'block';
    }
  }
  
  // Обработчик подтверждения добавления
  if (confirmBulkAddButton) {
    confirmBulkAddButton.addEventListener('click', function() {
      const selectedPlanId = planSelect.value;
      const selectedData = JSON.parse(bulkAddModal.getAttribute('data-selected-data') || '[]');
      const eventDepartmentIds = selectedData.map(item => item.id);
      
      if (selectedPlanId && eventDepartmentIds.length > 0) {
        addEventsToPlan(selectedPlanId, eventDepartmentIds);
      }
    });
  }
  
  function addEventsToPlan(planId, eventDepartmentIds) {
    const formData = new FormData();
    eventDepartmentIds.forEach(id => {
      formData.append('event_department_ids[]', id);
    });
    
    fetch(`/plans/${planId}/bulk_add_events`, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url;
      } else if (response.ok) {
        return response.json();
      } else {
        throw new Error('Network response was not ok');
      }
    })
    .then(data => {
      if (data && data.success) {
        $(bulkAddModal).modal('hide');
        setTimeout(() => {
          window.location.reload();
        }, 500);
      } else if (data && data.error) {
        showError('Ошибка: ' + data.error);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showError('Произошла ошибка при добавлении мероприятий');
    });
  }
}