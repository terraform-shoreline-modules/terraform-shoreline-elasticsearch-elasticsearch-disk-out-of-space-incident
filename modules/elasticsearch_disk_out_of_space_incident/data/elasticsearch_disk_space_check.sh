bash

#!/bin/bash



# Set the AWS region

export AWS_DEFAULT_REGION=${REGION}



# Set the Elasticsearch instance ID

export INSTANCE_ID=${INSTANCE_ID}



# Set the Elasticsearch index name

export INDEX_NAME=${INDEX_NAME}



# Get the total disk space available on the instance

TOTAL_DISK_SPACE=$(aws ec2 describe-instance-attribute --instance-id $INSTANCE_ID --attribute blockDeviceMapping --output text | awk '{print $3}')



# Get the disk space free on the instance

FREE_DISK_SPACE=$(df -h | grep '/dev/xvda1' | awk '{print $4}')



# Calculate the percentage of disk space used

DISK_SPACE_USED_PERCENTAGE=$(echo "scale=2; (100-($FREE_DISK_SPACE/$TOTAL_DISK_SPACE)*100)" | bc)



# If the disk space used percentage is greater than 90%, check the Elasticsearch index retention policy

if [ $(echo "$DISK_SPACE_USED_PERCENTAGE > 90" | bc -l) -eq 1 ]; then

    RETENTION_PERIOD=$(aws es describe-elasticsearch-domain --domain-name ${ELASTICSEARCH_DOMAIN_NAME} --output text --query 'DomainStatus.EBSOptions.EBSEnabled | if_not_null(to_string(@))' | awk '{print $2}')



    # If the retention period is less than 30 days, send an alert

    if [ $RETENTION_PERIOD -lt 30 ]; then

        echo "Alert: Elasticsearch retention policy is not configured correctly. Retention period is less than 30 days."

    else

        echo "Elasticsearch index is filling up disk space, but retention policy seems to be well configured."

    fi

else

    echo "Disk space usage is normal."

fi