#! /bin/bash

cd /opt/bahmni-lab/migrations/liquibase
java -jar ./lib/liquibase-1.9.5.jar --contexts=bahmni --url=jdbc:postgresql://localhost:5432/clinlims --logLevel=warning --defaultsFile=liquibase.properties update