import { initEventForm } from '../events/form.js';


document.addEventListener('DOMContentLoaded', () => {
    initEventForm();
});

document.addEventListener('turbolinks:load', () => {
    initEventForm();
});