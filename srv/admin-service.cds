using { sap.capire.incidents as my } from '../db/schema';

/**
 * Service used by administrators to manage customers and incidents.
 */
service AdminService {
  entity Customers as projection on my.Customers;
  entity Incidents as projection on my.Incidents;
}
