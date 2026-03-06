
import { initResposiblePersonCreate } from '../responsible_persons/form.js';

document.addEventListener('DOMContentLoaded', () => {
    initResposiblePersonCreate();
});

document.addEventListener('turbolinks:load', () => {
    initResposiblePersonCreate();
});