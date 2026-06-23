const $ = window.$ || window.jQuery;
export function initRoleAssignmentModal() {
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
    });
        $('#assignRoleModal').modal('hide');
        setTimeout(() => location.reload(), 1000);
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