import { initPlanCreate } from '../plans/form.js';


document.addEventListener('DOMContentLoaded', () => {
    initPlanCreate();
});

document.addEventListener('turbolinks:load', () => {
    initPlanCreate();
});