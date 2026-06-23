import { initAssociations } from '../other/association.js';
import { initResponsiblePersonSearch } from '../responsible_persons/form.js';

if (window.InitManager) {
  InitManager.add(initAssociations);
  InitManager.add(initResponsiblePersonSearch);
}