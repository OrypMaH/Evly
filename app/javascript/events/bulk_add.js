// app/javascript/events/bulk_add.js
const $ = window.$ || window.jQuery;

export function initBulkAdd() {
  console.log('🔍 Инициализация bulk add');
  
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
  
  console.log('✅ Найдены элементы:', {
    bulkAddButton: !!bulkAddButton,
    selectAllCheckbox: !!selectAllCheckbox,
    eventCheckboxes: eventCheckboxes.length,
    bulkAddModal: !!bulkAddModal,
    planSelect: !!planSelect
  });
  
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
    if (bulkAddButton) {
      bulkAddButton.addEventListener('click', function() {
        console.log('👆 Кнопка bulk add нажата');
        const selectedEventDepartments = getSelectedEventDepartmentsData();
        console.log('Выбранные мероприятия:', selectedEventDepartments);
        
        if (selectedEventDepartments.length > 0) {
          openBulkAddModal(selectedEventDepartments);
        }
      });
    }
    
    // Инициализация Semantic UI компонентов
    try {
      $('.ui.checkbox').checkbox();
      $('.ui.dropdown').dropdown();
      console.log('✅ Semantic UI компоненты инициализированы');
    } catch (e) {
      console.error('❌ Ошибка инициализации Semantic UI:', e);
    }
    
    // Обновляем счетчик при загрузке
    updateSelectionCount();
  }
  
  function updateSelectionCount() {
    const selectedCount = getSelectedEventDepartmentsData().length;
    const hasSelection = selectedCount > 0;
    
    console.log('Обновление счетчика:', selectedCount);
    
    if (selectedCountSpan) {
      selectedCountSpan.textContent = selectedCount;
    }
    
    if (selectedCountLabel) {
      selectedCountLabel.style.display = hasSelection ? 'inline-block' : 'none';
    }
    
    if (bulkAddButton) {
      bulkAddButton.disabled = !hasSelection;
    }
    
    if (selectAllCheckbox) {
      const allChecked = eventCheckboxes.length > 0 && 
                         selectedCount === eventCheckboxes.length;
      selectAllCheckbox.checked = allChecked;
      try {
        $(selectAllCheckbox).checkbox('set checked', allChecked);
      } catch (e) {}
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
    console.log('📂 Открытие модального окна с данными:', selectedData);
    
    // Сохраняем выбранные данные в модальном окне
    bulkAddModal.setAttribute('data-selected-data', JSON.stringify(selectedData));
    
    // Обновляем счетчик в модальном окне
    if (selectedEventsCountSpan) {
      selectedEventsCountSpan.textContent = selectedData.length;
    }
    
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
    
    // Устанавливаем обработчики для модального окна перед открытием
    setupModalHandlers();
    
    // Показываем модальное окно
    try {
      $(bulkAddModal).modal('show');
      console.log('✅ Модальное окно открыто');
      
      // Загружаем планы сразу после открытия
      setTimeout(() => {
        console.log('⏰ Загрузка планов после открытия');
        loadPlansForEventDepartments(selectedData);
      }, 300);
    } catch (e) {
      console.error('❌ Ошибка открытия модального окна:', e);
    }
  }
  
  function setupModalHandlers() {
    console.log('🔧 Настройка обработчиков модального окна');
    
    // Удаляем старые обработчики, если они были
    $(bulkAddModal).off('click', '#confirmBulkAdd');
    
    // Обработчик подтверждения
    $('#confirmBulkAdd').off('click').on('click', function() {
      console.log('✅ Кнопка подтверждения нажата');
      const selectedPlanId = planSelect.value;
      const selectedData = JSON.parse(bulkAddModal.getAttribute('data-selected-data') || '[]');
      const eventDepartmentIds = selectedData.map(item => item.id);
      
      console.log('Добавление в план:', { planId: selectedPlanId, eventIds: eventDepartmentIds });
      
      if (selectedPlanId && eventDepartmentIds.length > 0) {
        addEventsToPlan(selectedPlanId, eventDepartmentIds);
      } else {
        showError('Выберите план');
      }
    });
    
    // Обработчик выбора плана
    $(planSelect).off('change').on('change', function() {
      console.log('📋 Выбран план:', this.value);
      updatePlanInfo(this.value);
      updateConfirmButton();
    });
  }
  
  function loadPlansForEventDepartments(selectedData) {
    console.log('🌐 Загрузка планов для мероприятий:', selectedData);
    
    const eventDepartmentIds = selectedData.map(item => item.id);
    console.log('ID мероприятий:', eventDepartmentIds);
    
    const startDates = selectedData
      .map(item => item.start_date ? new Date(item.start_date) : null)
      .filter(date => date !== null);
    
    const minStartDate = startDates.length > 0 ? 
      new Date(Math.min(...startDates)).toISOString().split('T')[0] : '';
    const maxStartDate = startDates.length > 0 ? 
      new Date(Math.max(...startDates)).toISOString().split('T')[0] : '';
    
    console.log('Диапазон дат:', { minStartDate, maxStartDate });
    
    const params = new URLSearchParams({
      for_bulk_add: 'true',
      event_department_ids: eventDepartmentIds.join(','),
      min_start_date: minStartDate,
      max_start_date: maxStartDate
    });

    const url = `/plans?${params}`;
    console.log('📡 URL запроса:', url);
    
    const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
    console.log('🔑 CSRF токен:', csrfToken ? 'найден' : 'не найден');

    fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      console.log('📥 Статус ответа:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      console.log('📦 Получены данные:', data);
      updatePlanSelect(data.plans || []);
    })
    .catch(error => {
      console.error('❌ Ошибка загрузки планов:', error);
      showError('Ошибка загрузки планов: ' + error.message);
      updatePlanSelect([]);
    });
  }
  
  function updatePlanSelect(plans) {
    console.log('🔄 Обновление списка планов, получено планов:', plans.length);
    
    planSelect.innerHTML = '<option value="">Выберите план...</option>';
    
    if (plans && plans.length > 0) {
      plans.forEach(plan => {
        const option = document.createElement('option');
        option.value = plan.id;
        option.textContent = `${plan.title} (${plan.start_date} - ${plan.end_date})`;
        option.setAttribute('data-plan-info', JSON.stringify(plan));
        planSelect.appendChild(option);
      });
      
      console.log('✅ Добавлено опций:', plans.length);
    } else {
      console.log('⚠️ Нет подходящих планов');
      const option = document.createElement('option');
      option.value = "";
      option.textContent = "Нет подходящих планов";
      option.disabled = true;
      planSelect.appendChild(option);
    }
    
    try {
      $(planSelect).dropdown('refresh');
      console.log('✅ Dropdown обновлен');
    } catch (e) {
      console.error('❌ Ошибка обновления dropdown:', e);
    }
    
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
        try {
          const plan = JSON.parse(selectedOption.getAttribute('data-plan-info'));
          
          planTitle.textContent = plan.title;
          planPeriod.textContent = `${plan.start_date} - ${plan.end_date}`;
          planEventsCount.textContent = plan.events_count || 0;
          planInfo.style.display = 'block';
          console.log('📋 Информация о плане:', plan);
        } catch (e) {
          console.error('❌ Ошибка парсинга информации о плане:', e);
          planInfo.style.display = 'none';
        }
      } else {
        planInfo.style.display = 'none';
      }
    } else {
      planInfo.style.display = 'none';
    }
  }
  
  function updateConfirmButton() {
    const selectedPlanId = planSelect.value;
    const hasPlans = planSelect.options.length > 1;
    confirmBulkAddButton.disabled = !selectedPlanId || !hasPlans;
    console.log('🔘 Кнопка подтверждения:', confirmBulkAddButton.disabled ? 'выключена' : 'включена');
  }
  
  function resetModal() {
    console.log('🔄 Сброс модального окна');
    planSelect.value = '';
    try {
      $(planSelect).dropdown('refresh');
    } catch (e) {}
    document.getElementById('planInfo').style.display = 'none';
    document.getElementById('periodInfo').style.display = 'none';
    document.getElementById('modalError').style.display = 'none';
    confirmBulkAddButton.disabled = true;
  }
  
  function showError(message) {
    console.error('❌ Ошибка:', message);
    const errorDiv = document.getElementById('modalError');
    if (errorDiv) {
      errorDiv.innerHTML = `<div class="ui error message">${message}</div>`;
      errorDiv.style.display = 'block';
    }
  }
  
  function addEventsToPlan(planId, eventDepartmentIds) {
    console.log('➕ Добавление мероприятий в план:', { planId, eventDepartmentIds });
    
    const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
    
    fetch(`/plans/${planId}/plan_events/bulk_create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({
        event_department_ids: eventDepartmentIds
      })
    })
    .then(response => {
      console.log('📥 Статус ответа:', response.status);
      
      if (response.redirected) {
        console.log('🔄 Редирект на:', response.url);
        window.location.href = response.url;
      } else if (response.ok) {
        return response.json();
      } else {
        throw new Error('Network response was not ok');
      }
    })
    .then(data => {
      if (data) {
        console.log('📦 Данные ответа:', data);
        if (data.success) {
          console.log('✅ Успешно добавлено');
          $(bulkAddModal).modal('hide');
          setTimeout(() => {
            window.location.reload();
          }, 500);
        } else if (data.error) {
          showError('Ошибка: ' + data.error);
        }
      }
    })
    .catch(error => {
      console.error('❌ Ошибка:', error);
      showError('Произошла ошибка при добавлении мероприятий');
    });
  }
}