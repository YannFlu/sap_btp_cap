using { sap.capire.incidents as my } from '../db/schema';

/**
 * Service used by support personell, i.e. the incidents' 'processors'.
 */
service ProcessorService {

  @odata.draft.enabled
  entity Incidents as projection on my.Incidents;

  entity Customers as projection on my.Customers;

  @readonly entity Status as projection on my.Status;
  @readonly entity Urgency as projection on my.Urgency;
}

/** For display in lists of values */
annotate ProcessorService.Customers with @UI.Identification: [{ Value: name }];
annotate ProcessorService.Incidents with @(
  UI.HeaderInfo: {
    TypeName      : '{i18n>Incident}',
    TypeNamePlural: '{i18n>Incidents}',
    Title         : { Value: title },
    Description   : { Value: customer.name }
  }
);

//
// Workaround needed as long as this is not yet supported by our tools...
//
annotate ProcessorService.Incidents with {
  customer @Common: {
    Text: customer.name,
    TextArrangement: #TextOnly,
    ValueList: {
      $Type: 'Common.ValueListType',
      CollectionPath: 'Customers',
      Parameters: [
        { $Type: 'Common.ValueListParameterInOut',
          LocalDataProperty: customer_ID,
          ValueListProperty: 'ID'
        },
        { $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'firstName'
        },
        { $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'lastName'
        },
        { $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'email'
        }
      ]
    }
  }
}
