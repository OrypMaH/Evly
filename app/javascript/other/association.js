// app/javascript/packs/responsible_people.js
export function initAssociations(){
    function addAssociation(event, link) {
    event.preventDefault();
    
    const data = link.dataset;
    const fields = data.fields;
    const association = data.association;
    const insertionNode = document.querySelector(data.insertionNode || `#${association}`);
  if (insertionNode) {
    const newId = new Date().getTime();
    const newFields = fields.replace(new RegExp(`new_${association}`, 'g'), newId);
    
    const wrapper = document.createElement('div');
    wrapper.innerHTML = newFields;
    const newElement = wrapper.firstChild;
    
    insertionNode.appendChild(newElement);
    
    // Генерируем событие о загрузке формы
    const event = new CustomEvent('partial-loaded', {
      detail: {
        element: newElement,
        association: association,
        index: newId
      },
      bubbles: true
    });
    
    // Триггерим событие на новом элементе и на document
    newElement.dispatchEvent(event);
    document.dispatchEvent(event);
    
  }

    }

    // Глобальная функция для удаления
    function removeAssociation(event, link) {
    event.preventDefault();
    
    const container = link.closest('.responsible-person-fields');
    const destroyField = container.querySelector('input[name$="[_destroy]"]');
    
    if (destroyField) {
        destroyField.value = '1';
        container.style.display = 'none';
    } else {
        container.remove();
    }
    }

    // Подключаем функции к глобальному объекту window
    window.addAssociation = addAssociation;
    window.removeAssociation = removeAssociation;
}