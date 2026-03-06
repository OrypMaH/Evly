import { initEducationalOrganizationModal } from '../educational_organizations/modal.js';


document.addEventListener('DOMContentLoaded', () => {
    initEducationalOrganizationModal();
});

document.addEventListener('turbolinks:load', () => {
    initEducationalOrganizationModal();
});