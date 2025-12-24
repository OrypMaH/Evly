
import { initApproveParticipationModal } from '../events/approve.js';
import { initBulkAdd } from '../events/bulk_add.js';
import { initOfferParticipationModal } from '../events/offer.js';


document.addEventListener('DOMContentLoaded', () => {
    initApproveParticipationModal();
    initBulkAdd();
    initOfferParticipationModal();
});

document.addEventListener('turbolinks:load', () => {
    initApproveParticipationModal();
    initBulkAdd();
    initOfferParticipationModal();
});