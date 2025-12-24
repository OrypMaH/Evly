import { initRoleAssignmentModal } from '../roles/assign.js';


document.addEventListener('DOMContentLoaded', () => {
    initRoleAssignmentModal();
});

document.addEventListener('turbolinks:load', () => {
    initRoleAssignmentModal();
});