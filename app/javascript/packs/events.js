
import { initApproveParticipationModal } from '../events/approve.js';
import { initDirectionFormat } from '../events/direction.js';
import { initBulkAdd } from '../events/bulk_add.js';
import { initOfferParticipationModal } from '../events/offer.js';


document.addEventListener('DOMContentLoaded', () => {
    initApproveParticipationModal();
    initDirectionFormat();
    initBulkAdd();
    initOfferParticipationModal();
});

document.addEventListener('turbolinks:load', () => {
    initApproveParticipationModal();
    initDirectionFormat();
    initBulkAdd();
    initOfferParticipationModal();
});