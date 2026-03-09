
import { initApproveParticipationModal } from '../events/approve.js';
import { initDirectionFormat } from '../events/direction.js';
import { initBulkAdd } from '../events/bulk_add.js';
import { initOfferParticipationModal } from '../events/offer.js';


if (window.InitManager) {
  InitManager.add(initApproveParticipationModal);
  InitManager.add(initDirectionFormat);
  InitManager.add(initBulkAdd);
  InitManager.add(initOfferParticipationModal);
}