// В начале файла
const $ = window.$ || window.jQuery;

export function initApproveParticipationModal() {
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
