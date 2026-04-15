using { ProcessorService } from '../srv/processor-service';

//
// Incidents List Report / Object Page
//
annotate ProcessorService.Incidents with @(
  UI.HeaderInfo: {
    Title         : { Value: title },
    Description   : { Value: customer.name },
    TypeName      : 'Incident',
    TypeNamePlural: 'Incidents'
  },
  UI.LineItem: [
    { Value: title,             Label: '{i18n>Title}' },
    { Value: customer.name,     Label: '{i18n>Customer}' },
    { Value: status.descr,      Label: '{i18n>Status}',      Criticality: status.criticality  },
    { Value: urgency.descr,     Label: '{i18n>Urgency}' }
  ],
  UI.SelectionFields: [ status_code, urgency_code ],
  UI.FieldGroup #GeneralInformation: {
    Data: [
      { Value: title },
      { Value: customer_ID,     Label: '{i18n>Customer}' },
      { Value: status_code,     Label: '{i18n>Status}' },
      { Value: urgency_code,    Label: '{i18n>Urgency}' }
    ]
  },
  UI.FieldGroup #Details: {
    Data: [
      { Value: customer.firstName, Label: '{i18n>FirstName}' },
      { Value: customer.lastName,  Label: '{i18n>LastName}' },
      { Value: customer.email,     Label: '{i18n>Email}' },
      { Value: customer.phone,     Label: '{i18n>Phone}' }
    ]
  },
  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>General}',  Target: '@UI.FieldGroup#GeneralInformation' },
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>Customer}', Target: '@UI.FieldGroup#Details' },
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>Conversation}', Target: 'conversation/@UI.LineItem' }
  ]
);

annotate ProcessorService.Incidents.conversation with @(
  UI.LineItem: [
    { Value: timestamp, Label: '{i18n>Date}' },
    { Value: author,    Label: '{i18n>Author}' },
    { Value: message,   Label: '{i18n>Message}' }
  ]
);
