## NepalEHR Scripts

These are the various scripts created to perform repetitive tasks involved in the installation as well as deployment of NepalEHR.

Some scripts were also created as janky fixes for major bugs such as the Odoo Tick script.

## Instructions

Step by step guide on how and when these scripts are to be used will be provided in the NIC Atlassian.

## Files
<pre>
|-- bahmni-odoo-tick.sh <- Script to restart a failed odoo service
|-- bahmni-prep.sh <- Script to prepare a vanilla CentOS 7.6 for NepalEHR installation
|-- bahmni-service-check.sh <- Script to check if all bahmni services are running properly
|-- bahmni-ssl.sh <- Script to generate the SSL Certificates to be used for the Server
|-- migrate.sh <- Liquibase migration
</pre>