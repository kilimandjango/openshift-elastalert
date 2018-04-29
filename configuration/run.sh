#!/usr/bin/env bash

#until netstat -ln  | grep :9200; do echo -n "."; sleep 1; done

# --debug option will result in alerts NOT being sent

cd $ELASTALERT_HOME && \
    elastalert-create-index --config $ELASTALERT_HOME/config/config.yaml && \
    python -m elastalert.elastalert --config $ELASTALERT_HOME/config/config.yaml --verbose --start $(date --iso-8601)T00:00:00 
