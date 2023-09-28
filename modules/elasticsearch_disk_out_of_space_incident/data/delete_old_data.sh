bash

#!/bin/bash



# Set variables

ELASTICSEARCH_INDEX=${INDEX_NAME}

DAYS_TO_KEEP=${NUMBER_OF_DAYS_TO_KEEP_DATA}



# Delete old data

aws es delete-by-query \

    --index $ELASTICSEARCH_INDEX \

    --query '{"range": {"@timestamp": {"lt": "now-'$DAYS_TO_KEEP'd"}}}'