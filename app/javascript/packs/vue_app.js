import Vue from 'vue';
import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
import '@mdi/font/css/materialdesignicons.css';
import ru from 'vuetify/es5/locale/ru';
import axios from 'axios';

// Настройка axios
const csrfToken = document.querySelector('[name="csrf-token"]')?.getAttribute('content');
if (csrfToken) {
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

// Настройка Vuetify
Vue.use(Vuetify);

const vuetify = new Vuetify({
  lang: {
    locales: { ru },
    current: 'ru',
  },
  theme: {
    themes: {
      light: {
        primary: '#016559',      
        secondary: '#ff9800',    
        accent: '#82B1FF',
        error: '#FF5252',
        info: '#2196F3',
        success: '#4CAF50',
        warning: '#FFC107'
      }
    }
  },
  icons: {
    iconfont: 'mdi'  
  }
});

window.mountVueApp = (component, elementId, props = {}) => {
  const element = document.getElementById(elementId);
  if (!element) {
    console.error(`Element #${elementId} not found`);
    return;
  }
  
  new Vue({
    vuetify,
    render: h => h(component, { props })
  }).$mount(`#${elementId}`);
};

