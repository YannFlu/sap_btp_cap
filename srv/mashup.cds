using { ProcessorService } from './processor-service';
using { AdminService } from './admin-service';

// Authorization for ProcessorService (used by Fiori UI and support agents)
annotate ProcessorService with @(requires: 'support');
annotate ProcessorService.Customers with @(restrict: [
  { grant: 'READ', to: 'support' },
  { grant: '*',    to: 'admin'   }
]);

// Authorization for AdminService
annotate AdminService with @(requires: 'admin');
