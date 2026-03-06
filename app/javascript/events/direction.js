// app/javascript/directions/tooltips.js
const $ = window.$ || window.jQuery;

export function initDirectionFormat() {
  // Инициализация тултипов для меток направлений
  $('.direction-label').popup({
    hoverable: true,
    position: 'top left',
    delay: {
      show: 3000,
      hide: 300
    }
  });
  
  
  // Инициализация тултипов для выпадающих списков направлений (если будут)
  $('.direction-dropdown').dropdown();
}
