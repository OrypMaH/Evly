// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "jquery";
import "../../../vendor/assets/javascripts/semantic.min.js";

Rails.start()
Turbolinks.start();
ActiveStorage.start();

function showFlashMessage(type, message) {
  const messageHtml = `
    <div class="ui ${type} message">
      <i class="close icon"></i>
      <div class="header">${message}</div>
    </div>
  `;
  
  const mainContainer = document.querySelector('.ui.main.container');
  if (mainContainer) {
    mainContainer.insertAdjacentHTML('afterbegin', messageHtml);
    initCloseButtons();
    
    setTimeout(() => {
      const msg = mainContainer.querySelector('.ui.message:first-child');
      if (msg) msg.remove();
    }, 5000);
  }
}
function initCloseButtons() {
  document.querySelectorAll('.message .close').forEach(button => {
    button.addEventListener('click', function() {
      this.closest('.message').remove();
    });
  });
}
// События
function initializeModals() {
  initSemanticUI();
  initRoleAssignmentModal();
  initApproveParticipationModal();
  initOfferParticipationModal();
  initCloseButtons(); // инициализируем кнопки закрытия
}

// Обновляем обработчики событий
document.addEventListener('DOMContentLoaded', initializeModals);
document.addEventListener('turbolinks:load', initializeModals);

// Функция инициализации Semantic UI
function initSemanticUI() {
  if ($('.ui.dropdown').length) $('.ui.dropdown').dropdown();
  if ($('.ui.checkbox').length) $('.ui.checkbox').checkbox();
  if ($('.ui.progress').length) $('.ui.progress').progress();
  if ($('.menu .item').length) $('.menu .item').tab();
}

// Функция инициализации модального окна
function initRoleAssignmentModal() {
  const assignRoleButtons = document.querySelectorAll('.assign-role-btn');
  const assignRoleModal = document.getElementById('assignRoleModal');
  
  // Если модального окна нет на странице - выходим
  if (!assignRoleModal) return;
  
  let currentRoleId = null;
  let selectedUserId = null;
  
  // Открытие модального окна
  assignRoleButtons.forEach(button => {
    button.addEventListener('click', function() {
      currentRoleId = this.dataset.roleId;
      document.getElementById('modalRoleName').textContent = this.dataset.roleName;
      resetModal();
      $('#assignRoleModal').modal('show');
    });
  });
  
  // Простой поиск
  const searchInput = document.getElementById('userSearchInput');
  const searchResults = document.querySelector('#userSearch .results');
  
  // Если поля поиска нет - выходим
  if (!searchInput) return;
  
  searchInput.addEventListener('input', function(e) {
    const query = e.target.value.trim();
    
    if (query.length < 2) {
      clearResults();
      return;
    }
    
    setTimeout(() => {
      searchUsers(query);
    }, 300);
  });
  
  // Предотвращаем стандартное поведение формы
  
  // Предотвращаем Enter в поле поиска
  searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      return false;
    }
  });
  
  function searchUsers(query) {
    fetch(`/users/search?q=${encodeURIComponent(query)}`)
      .then(response => {
        if (!response.ok) throw new Error('Network error');
        return response.json();
      })
      .then(data => {
        displayResults(data.users || []);
      })
      .catch(error => {
        console.error('Search error:', error);
        displayResults([]);
      });
  }
  
  function displayResults(users) {
    searchResults.innerHTML = '';
    
    if (users.length === 0) {
      searchResults.innerHTML = '<div class="message">Пользователи не найдены</div>';
      searchResults.style.display = 'block';
      return;
    }
    
    users.forEach(user => {
      const resultItem = document.createElement('div');
      resultItem.className = 'result';
      resultItem.setAttribute('data-user-id', user.id);
      resultItem.innerHTML = `
        <div class="content">
          <div class="title">${user.full_name}</div>
        </div>
      `;
      
      resultItem.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        selectUser(user.id, user.full_name);
      });
      
      // Дополнительная защита - предотвращаем любые клики
      resultItem.addEventListener('mousedown', function(e) {
        e.preventDefault();
      });
      
      searchResults.appendChild(resultItem);
    });
    
    searchResults.style.display = 'block';
  }
  
  function selectUser(userId, userName) {
    selectedUserId = userId;
    document.getElementById('selectedUserName').textContent = userName;
    document.getElementById('selectedUser').style.display = 'block';
    document.getElementById('confirmAssign').disabled = false;
    
    searchInput.value = '';
    clearResults();
  }
  
  function clearResults() {
    searchResults.innerHTML = '';
    searchResults.style.display = 'none';
  }
  
  // Подтверждение назначения роли
  document.getElementById('confirmAssign').addEventListener('click', function(e) {
    e.preventDefault();
    if (!selectedUserId || !currentRoleId) return;
    
    fetch(`/roles/${currentRoleId}/assign_user`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ user_id: selectedUserId })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        alert(data.message);
        $('#assignRoleModal').modal('hide');
        setTimeout(() => location.reload(), 1000);
      } else {
        alert('Ошибка: ' + data.message);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Произошла ошибка при назначении роли');
    });
  });
  
  // Сброс состояния
  function resetModal() {
    selectedUserId = null;
    searchInput.value = '';
    document.getElementById('selectedUser').style.display = 'none';
    document.getElementById('confirmAssign').disabled = true;
    clearResults();
  }
  
  // Закрытие результатов при клике вне поля
  document.addEventListener('click', function(e) {
    if (!e.target.closest('#userSearch')) {
      clearResults();
    }
  });
  
  // Предотвращаем закрытие модального окна при клике на результаты
  searchResults.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  
}
//Approve form
function initApproveParticipationModal() {
  const approveButtons = document.querySelectorAll('.approve-button');
  const approveModal = document.getElementById('approveParticipationModal');
  const form = document.getElementById('approveParticipationForm');
  
  if (!approveModal || !form) return;
  
  approveButtons.forEach(button => {
    button.addEventListener('click', function() {
      const eventDepartmentId = this.getAttribute('data-event-department-id');
      const eventTitle = this.getAttribute('data-event-title');
      
      form.action = `/offered_event_departments/${eventDepartmentId}/approve`;
      document.getElementById('approveModalHeader').textContent = 
        `Утверждение участия: ${eventTitle}`;
      document.getElementById('modalParticipantsCount').value = 1;
      
      $(approveModal).modal('show');
    });
  });
  
  // Оставляем обычную отправку формы
  form.addEventListener('submit', function() {
    // Даем время на отправку и закрываем модалку
    setTimeout(() => {
      $(approveModal).modal('hide');
    }, 100);
  });
}

// Функция обработки отправки формы

function initOfferParticipationModal() {
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