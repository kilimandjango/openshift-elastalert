# Elastalert Alerting for EFK in OpenShift

ElastAlert is a simple framework for alerting on anomalies, spikes, or other patterns of interest from data in Elasticsearch which is developed and maintained at Yelp:  
https://github.com/Yelp/elastalert

This repository builds a Dockerfile of ElastAlert which is ready to run in the OpenShift Container Platform.

ElastAlert requires the key and certificate of the ElasticSearch curator to talk to the ElasticSearch API.

This repository also contains a default configuration for ElastAlert otherwise the Container will not start.
To setup a custom configuration you can setup a custom configmap.

# Build

First create a new project:  
`$ oc new-project elastalert`

Within this project trigger a new build:  
`$ oc new-build https://github.com/kilimandjango/openshift-elastalert.git --strategy=Docker --name=elastalert-ocp`

Alternatively you can also clone the git repository and trigger a local Docker build!

Run the App:  
`$ oc new-app --image elastalert-ocp`

# Configuration

Two configmaps are needed which must be mounted in the deploymentconfig which was automatically created by using `oc new-app` command.

The first configmap is `config.yaml`. You can add it by clicking the **Create Config Map** button Paste the following content into the field.
Set the `Name` to **config-cm** and the `key` to **config.yaml**:  

```bash
# This is the folder that contains the rule yaml files
# Any .yaml file will be loaded as a rule
rules_folder: rules

#
scan_subdirectories: false

# How often ElastAlert will query elasticsearch
# The unit can be anything from weeks to seconds
run_every:
  minutes: 1

# ElastAlert will buffer results from the most recent
# period of time, in case some log sources are not in real time
buffer_time:
  minutes: 15

# The elasticsearch service for metadata writeback
# Note that every rule can have it's own elasticsearch host
es_host: logging-es

# The elasticsearch port
es_port: 9200

# The index on es_host which is used for metadata storage
# This can be a unmapped index, but it is recommended that you run
# elastalert-create-index to set a mapping
writeback_index: elastalert_status

# If an alert fails for some reason, ElastAlert will retry
# sending the alert until this time period has elapsed
alert_time_limit:
  days: 2

use_ssl: True
verify_certs: True

# The secrets from the curator must be mounted!
ca_certs: /etc/curator/keys/ca
client_cert: /etc/curator/keys/cert
client_key: /etc/curator/keys/key

# smpt settings
email: <DEST_MAIL_ADDRESS>
smpt_host: '<SMTP_HOST'
smtp_port: <SMTP_PORT>
from_addr: '<SOURCE_MAIL_ADDRESS>'
```
Two steps are essential. The first one is to set the Service Name of the Elasticsearch in OpenShift as the **es_host** and the port as the **es_port**:  
```bash
 es_host: logging-es
 es_port: 9200
 ```

 The next step is to set the secrets of the Elasticsearch Curator accordingly to **ca_certs**, **client_cert** and **client_key**:  
 ```bash
 ca_certs: /etc/curator/keys/ca
 client_cert: /etc/curator/keys/cert
 client_key: /etc/curator/keys/key
 ```
**Adding the Config Map**  
Add the Config Map to the application by clicking on the button **Add to Application**. Choose the ElastAlert application and set the mount path of the volume to:
`/opt/elastalert/config`

**Updating the Config Map**  
To update the Config Map it can be edited over the web console. After changes are done the ElastAlert pod needs to be restarted.

# rules

Any yaml files in the rules folder will be automatically recognized.

Custom rules can be added the same way as the configuration in form of a Config Map:  
- Create the Config Map
- Paste the yaml content into the field
- Set the name to something like rules-alerting
- Set the key to something like rules-alerting.yaml
- Add the Config Map to the Application
- Mount the Config Map as a volume to /opt/elastalert/rules

An exemplary rules file:
```bash
# (Required)

# Rule name, must be unique

name: OutOfMemoryError



# (Required)

# Type of alert.

# the frequency rule type alerts when num_events events occur with timeframe time

type: frequency



# (Required)

# Index to search, wildcard supported

index: logstash-%Y.%m.%d*



use_strftime_index: true



# (Required, frequency specific)

# Alert when this many documents matching the query occur within a timeframe

num_events: 1



# (Required, frequency specific)

# num_events must occur within this amount of time to trigger an alert

timeframe:

  hours: 1



# (Required)

# A list of Elasticsearch filters used for find events

# These filters are joined with AND and nested in a filtered query

# For more info: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl.html

filter:

- query_string:

    query: "message: OutOfMemoryError OR log: OutOfMemoryError"



# (Required)

# The alert is use when a match is found

alert:

- "slack"
```
