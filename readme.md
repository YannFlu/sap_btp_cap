# Incident Management - CAP on SAP BTP

A sample application built with the [SAP Cloud Application Programming Model](https://cap.cloud.sap) (CAP), following the [SAP BTP Developer's Guide](https://github.com/SAP-samples/btp-developer-guide-cap).

The app lets a support team manage customer incidents. It is designed to run on **SAP BTP Cloud Foundry** with:

- **HANA Cloud** as persistence
- **XSUAA** for authentication and authorization (roles: `Support`, `Admin`)
- **Application Router** with `@sap/approuter`
- **HTML5 Apps Repository** for the Fiori Elements UI
- **Destination Service** for service tile integration

## Project layout

```
.
├── app/                         # UI & Approuter
│   ├── router/                  #  Application router (Node.js)
│   ├── incidents/webapp/        #  Fiori Elements List Report / Object Page
│   └── fiori.cds                #  Fiori UI annotations
├── db/
│   ├── schema.cds               # Incidents, Customers, Status, Urgency
│   └── data/                    # Sample CSV data
├── srv/
│   ├── processor-service.cds    # ProcessorService (used by support)
│   ├── admin-service.cds        # AdminService
│   └── mashup.cds               # @requires: 'support' / 'admin'
├── xs-security.json             # XSUAA scopes & role templates
├── mta.yaml                     # Multitarget Application descriptor
└── package.json
```

## Prerequisites

| Tool              | Install                                                    |
| ----------------- | ---------------------------------------------------------- |
| Node.js 20/22     | <https://nodejs.org>                                       |
| `@sap/cds-dk`     | `npm install -g @sap/cds-dk`                               |
| `mbt`             | `npm install -g mbt`                                       |
| Cloud Foundry CLI | <https://docs.cloudfoundry.org/cf-cli/install-go-cli.html> |
| MTA plugin        | `cf install-plugin multiapps`                              |
| BTP CLI (optional)| <https://tools.hana.ondemand.com/#cloud>                  |

You also need an **SAP BTP subaccount** with a **Cloud Foundry space** and the following entitlements:

- SAP HANA Cloud (service plan `hana`) and HANA Cloud Tools
- Authorization and Trust Management (`xsuaa`, plan `application`)
- HTML5 Application Repository Service (`html5-apps-repo`, plans `app-host` + `app-runtime`)
- Destination Service (`destination`, plan `lite`)

## Local development

```bash
npm install
cds watch
```

This starts an in-memory SQLite database, serves `/odata/v4/processor/` and `/odata/v4/admin/`, and opens a Fiori preview. Authorization is disabled locally so you don't need JWT tokens.

## Deploy to SAP BTP Cloud Foundry

### 1. Log in

```bash
cf login -a https://api.cf.<region>.hana.ondemand.com
```

### 2. Create the HANA Cloud instance (once per space)

If your space doesn't have HANA Cloud yet, create one from the BTP cockpit _or_ via:

```bash
cf create-service hana-cloud hana incident-mgmt-hana-cloud
```

Then bind the `hdi-shared` runtime later via the MTA deploy.

> Tip: if you already have a HANA Cloud instance, nothing to do — the MTA will provision a new `hdi-shared` tenant on top.

### 3. Build the MTA archive

```bash
mbt build --mtar=incidents-mgmt.mtar
```

The archive is produced under `./mta_archives/incidents-mgmt.mtar`.

### 4. Deploy

```bash
cf deploy mta_archives/incidents-mgmt.mtar
```

This creates the following services and apps in your CF space:

| Module / Resource                 | Type                                     |
| --------------------------------- | ---------------------------------------- |
| `sap_btp_cap-srv`                 | Node.js CAP service                      |
| `sap_btp_cap-db-deployer`         | HANA HDI content deployer                |
| `sap_btp_cap`                     | `@sap/approuter`                         |
| `sap_btp_cap-app-deployer`        | Pushes `incidents-ui.zip` to html5-repo  |
| `sap_btp_cap-auth`                | XSUAA (`xs-security.json`)               |
| `sap_btp_cap-db`                  | HANA HDI container                       |
| `sap_btp_cap-html5-repo-host/-runtime` | HTML5 Apps Repo                     |
| `sap_btp_cap-destination`         | Destination service                      |

### 5. Assign role collections

After deployment, go to the **BTP Cockpit → Security → Role Collections** and add the auto-generated collections to your user:

- `IncidentsSupport` — Read incidents, customers
- `IncidentsAdmin` — Full admin rights

### 6. Open the app

Retrieve the approuter URL:

```bash
cf app sap_btp_cap | grep routes
```

Open the URL in a browser. You'll be redirected to XSUAA for login and then land on the Incident Management Fiori Elements UI.

For Work Zone integration, add the `incidents-ui` app to a site in **SAP Build Work Zone, Standard Edition**.

## Useful commands

```bash
cds compile srv --to openapi     # generate OpenAPI spec
cds build --production           # produce gen/srv and gen/db
mbt build --mtar=incidents.mtar  # package for BTP
cf deploy mta_archives/*.mtar    # deploy to Cloud Foundry
cf undeploy sap_btp_cap --delete-services  # tear down
```

## Further reading

- SAP BTP Developer's Guide: <https://github.com/SAP-samples/btp-developer-guide-cap>
- CAP documentation: <https://cap.cloud.sap>
- Incident Management mission: <https://developers.sap.com/mission.btp-developers-guide-cap.html>
