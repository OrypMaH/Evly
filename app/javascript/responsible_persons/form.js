// app/javascript/packs/responsible_people.js
const $ = window.$ || window.jQuery;

export function initResponsiblePersonSearch() {
  console.log('🔧 Инициализация ответственных лиц');
  
  const showAddFormBtn = document.getElementById('show-add-form-btn');
  const quickAddForm = document.getElementById('quick-add-form');
  const cancelBtn = document.getElementById('cancel-inline-add');
  const searchInput = document.getElementById('inline-user-search-input');
  const searchResults = document.querySelector('#inline-user-search .results');
  const roleSelect = document.getElementById('inline-role-select');
  const confirmBtn = document.getElementById('confirm-inline-add');
  
  // Если кнопка не найдена - выходим
  if (!showAddFormBtn) {
    console.log('⏩ Не на странице редактирования мероприятия');
    return;
  }
  
  // Переменные для хранения выбранных данных
  let selectedUserId = null;
  let selectedUserName = null;
  let searchTimeout = null;
  
  // Инициализация Semantic UI компонентов
  initializeSemanticUI();
  
  // Показать форму добавления
  showAddFormBtn.addEventListener('click', function() {
    quickAddForm.style.display = 'block';
    showAddFormBtn.style.display = 'none';
    searchInput.focus();
  });
  
  // Отмена добавления
  cancelBtn.addEventListener('click', function() {
    resetForm();
  });
  
  // Поиск пользователей
  searchInput.addEventListener('input', function(e) {
    const query = e.target.value.trim();
    
    if (searchTimeout) clearTimeout(searchTimeout);
    
    if (query.length < 2) {
      clearSearchResults();
      return;
    }
    
    searchTimeout = setTimeout(() => {
      searchUsers(query);
    }, 300);
  });
  
  // Предотвращаем отправку формы по Enter
  searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      return false;
    }
  });
  
  // Закрытие результатов при клике вне
  document.addEventListener('click', function(e) {
    const searchContainer = document.getElementById('inline-user-search');
    if (searchContainer && !searchContainer.contains(e.target)) {
      clearSearchResults();
    }
  });
  
  async function searchUsers(query) {
    try {
      const response = await fetch(`/users/search?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      });
      
      if (!response.ok) throw new Error('Network error');
      
      const data = await response.json();
      displaySearchResults(data.users || []);
    } catch (error) {
      console.error('Search error:', error);
      displaySearchResults([]);
    }
  }
  
  function displaySearchResults(users) {
    searchResults.innerHTML = '';
    
    if (users.length === 0) {
      searchResults.innerHTML = '<div class="message">Пользователи не найдены</div>';
      searchResults.style.display = 'block';
      return;
    }
    
    users.forEach(user => {
      const result = document.createElement('div');
      result.className = 'result';
      result.dataset.userId = user.id;
      result.dataset.userName = user.full_name;
      result.innerHTML = `
        <div class="content">
          <div class="title">${user.full_name}</div>
          <div class="description">${user.email || ''}</div>
        </div>
      `;
      
      result.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        selectUser(user.id, user.full_name);
      });
      
      searchResults.appendChild(result);
    });
    
    searchResults.style.display = 'block';
  }
  
  // ИСПРАВЛЕННАЯ функция selectUser
  async function selectUser(userId, userName) {
    console.log('👤 Выбран пользователь:', userId, userName);
    
    selectedUserId = userId;
    selectedUserName = userName;
    
    // Обновляем поле поиска
    searchInput.value = userName;
    clearSearchResults();
    
    // Загружаем роли
    try {
      const response = await fetch(`/users/${userId}/roles`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      });
      
      if (!response.ok) throw new Error('Failed to load roles');
      
      const roles = await response.json();
      console.log('📦 Получены роли:', roles);
      
      // Сохраняем родительский контейнер для dropdown
      const dropdownContainer = $(roleSelect).closest('.ui.dropdown');
      
      // Полностью уничтожаем старый dropdown
      if ($ && $.fn.dropdown) {
        $(roleSelect).dropdown('destroy');
      }
      
      // Очищаем select
      roleSelect.innerHTML = '';
      
      if (roles.length === 0) {
        // Если ролей нет
        roleSelect.innerHTML = '<option value="">У пользователя нет должностей</option>';
        roleSelect.disabled = true;
        confirmBtn.disabled = true;
      } else {
        // Добавляем опцию по умолчанию
        const defaultOption = document.createElement('option');
        defaultOption.value = '';
        defaultOption.textContent = 'Выберите должность';
        roleSelect.appendChild(defaultOption);
        
        // Добавляем роли
        roles.forEach(role => {
          const option = document.createElement('option');
          option.value = role.id;
          option.textContent = role.name;
          roleSelect.appendChild(option);
        });
        
        roleSelect.disabled = false;
        confirmBtn.disabled = true; // Станет active только когда выберут роль
      }
      
      // Принудительно показываем контейнер с ролями
      const roleContainer = document.getElementById('roleSelectContainer');
      if (roleContainer) {
        roleContainer.style.display = 'block';
      }
      
      // Переинициализируем Semantic UI dropdown
      if ($ && $.fn.dropdown) {
        console.log('🔄 Пересоздание Semantic UI dropdown');
        
        // Небольшая задержка для гарантии обновления DOM
        setTimeout(() => {
          $(roleSelect).dropdown({
            onChange: function(value) {
              confirmBtn.disabled = !value;
              console.log('Выбрана роль:', value);
            }
          });
          
          // Принудительно обновляем
          $(roleSelect).dropdown('refresh');
          
          // Убеждаемся, что dropdown видим
          $(roleSelect).closest('.ui.dropdown').removeClass('disabled');
          
          console.log('✅ Dropdown пересоздан');
        }, 50);
      }
      
    } catch (error) {
      console.error('Error loading roles:', error);
      showNotification('error', 'Ошибка загрузки должностей');
      
      roleSelect.innerHTML = '<option value="">Ошибка загрузки</option>';
      roleSelect.disabled = true;
      confirmBtn.disabled = true;
      
      if ($ && $.fn.dropdown) {
        $(roleSelect).dropdown('refresh');
      }
    }
  }
  
  // Обработчик выбора роли через нативный select
  roleSelect.addEventListener('change', function() {
    confirmBtn.disabled = !this.value;
    console.log('Выбрана роль (native):', this.value);
  });
  
  // Подтверждение добавления
  confirmBtn.addEventListener('click', function() {
    const roleId = roleSelect.value;
    const roleName = roleSelect.options[roleSelect.selectedIndex]?.text;
    
    if (selectedUserId && roleId) {
      // Проверяем, не добавлен ли уже этот пользователь
      if (isUserAlreadyAdded(selectedUserId)) {
        showNotification('error', 'Этот пользователь уже добавлен как ответственное лицо');
        return;
      }
      
      addResponsiblePersonToForm(
        selectedUserId,
        selectedUserName,
        roleId,
        roleName
      );
      resetForm();
      showNotification('success', 'Ответственное лицо добавлено');
    } else {
      showNotification('error', 'Выберите пользователя и должность');
    }
  });
  
  function isUserAlreadyAdded(userId) {
    const existingItems = document.querySelectorAll('#responsible-people-items .responsible-person-item');
    for (let item of existingItems) {
      if (item.style.display !== 'none') {
        const existingUserId = item.querySelector('.user-id-field')?.value;
        if (existingUserId == userId) return true;
      }
    }
    return false;
  }
  
  function clearSearchResults() {
    if (searchResults) {
      searchResults.innerHTML = '';
      searchResults.style.display = 'none';
    }
  }
  
  function resetForm() {
    // Скрываем форму
    quickAddForm.style.display = 'none';
    showAddFormBtn.style.display = 'inline-block';
    
    // Очищаем поля
    searchInput.value = '';
    roleSelect.innerHTML = '<option value="">Сначала выберите пользователя</option>';
    roleSelect.disabled = true;
    
    // Скрываем контейнер с ролями
    const roleContainer = document.getElementById('roleSelectContainer');
    if (roleContainer) {
      roleContainer.style.display = 'none';
    }
    
    // Сбрасываем выбранные данные
    selectedUserId = null;
    selectedUserName = null;
    
    // Очищаем результаты поиска
    clearSearchResults();
    
    // Переинициализируем dropdown
    if ($ && $.fn.dropdown) {
      $(roleSelect).dropdown('destroy');
      $(roleSelect).dropdown();
    }
  }
  
  function initializeSemanticUI() {
    if ($ && $.fn.dropdown) {
      $('.ui.dropdown').dropdown();
      console.log('✅ Semantic UI инициализирован');
    }
  }
  
  // Инициализация кнопок удаления
  initRemoveButtons();
}

// Вспомогательная функция для добавления в список
function addResponsiblePersonToForm(userId, userName, roleId, roleName) {
  console.log('➕ Добавление:', { userId, userName, roleId, roleName });
  
  const container = document.getElementById('responsible-people-items');
  const template = document.getElementById('new-responsible-person-template');
  const noMessage = document.getElementById('no-responsible-message');
  
  if (!container || !template) {
    console.error('❌ Не найдены container или template');
    return;
  }
  
  // Генерируем уникальный индекс
  const index = new Date().getTime();
  
  // Получаем HTML из шаблона и заменяем NEW_RECORD на индекс
  let html = template.innerHTML.replace(/NEW_RECORD/g, index);
  
  // Создаем временный div для парсинга
  const temp = document.createElement('div');
  temp.innerHTML = html;
  const newItem = temp.firstElementChild;
  
  // Заполняем данные
  const userIdField = newItem.querySelector('.user-id-field');
  const roleIdField = newItem.querySelector('.role-id-field');
  const userNameSpan = newItem.querySelector('.user-name');
  const roleNameSpan = newItem.querySelector('.role-name');
  
  if (userIdField) userIdField.value = userId;
  if (roleIdField) roleIdField.value = roleId;
  if (userNameSpan) userNameSpan.textContent = userName;
  if (roleNameSpan) roleNameSpan.textContent = roleName;
  
  // Добавляем в список
  container.appendChild(newItem);
  
  // Показываем контейнер и скрываем сообщение
  container.style.display = 'block';
  if (noMessage) noMessage.style.display = 'none';
  
  // Инициализируем кнопку удаления
  const removeBtn = newItem.querySelector('.remove-responsible-btn');
  if (removeBtn) initRemoveButton(removeBtn);
  
  console.log('✅ Ответственное лицо добавлено в форму');
}

// Инициализация кнопок удаления
function initRemoveButtons() {
  document.querySelectorAll('.remove-responsible-btn').forEach(btn => {
    initRemoveButton(btn);
  });
}

function initRemoveButton(btn) {
  // Удаляем старые обработчики
  const newBtn = btn.cloneNode(true);
  btn.parentNode.replaceChild(newBtn, btn);
  
  newBtn.addEventListener('click', function(e) {
    e.preventDefault();
    
    const item = this.closest('.responsible-person-item');
    const destroyFlag = item.querySelector('.destroy-flag');
    
    if (destroyFlag) {
      destroyFlag.value = '1';
      item.style.display = 'none';
    } else {
      item.remove();
    }
    
    // Проверяем, остались ли элементы
    const container = document.getElementById('responsible-people-items');
    const visibleItems = Array.from(container.children).filter(
      child => child.style.display !== 'none'
    );
    
    const noMessage = document.getElementById('no-responsible-message');
    if (noMessage) {
      noMessage.style.display = visibleItems.length === 0 ? 'block' : 'none';
    }
    
    showNotification('info', 'Ответственное лицо удалено');
  });
}

function showNotification(type, message) {
  if ($ && $.fn.toast) {
    $('body').toast({
      title: type === 'success' ? 'Успех' : type === 'error' ? 'Ошибка' : 'Информация',
      message: message,
      class: type,
      showProgress: 'bottom',
      position: 'top right',
      displayTime: 2000
    });
  } else {
    console.log(`${type}: ${message}`);
  }
}

// Автоматическая инициализация при загрузке страницы
document.addEventListener('turbolinks:load', function() {
  if (typeof initResponsiblePersonSearch === 'function') {
    initResponsiblePersonSearch();
  }
});