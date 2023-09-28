bash

#!/bin/bash



# Set AWS region

export AWS_DEFAULT_REGION=${AWS_REGION}



# Set Elasticsearch domain name

export DOMAIN_NAME=${ELASTICSEARCH_DOMAIN_NAME}



# Set S3 bucket name for Elasticsearch backups

export S3_BUCKET_NAME=${S3_BUCKET_NAME}



# Check Elasticsearch disk space usage

ELASTICSEARCH_USAGE=$(aws es describe-elasticsearch-domain --domain-name $ELASTICSEARCH_DOMAIN_NAME --query 'DomainStatus.EBSOptions.VolumeSize' --output text)

ELASTICSEARCH_SPACE_USED=$(aws es describe-elasticsearch-domain --domain-name $ELASTICSEARCH_DOMAIN_NAME --query 'DomainStatus.EBSOptions.VolumeUsedSpace' --output text)

ELASTICSEARCH_SPACE_AVAILABLE=$(($ELASTICSEARCH_USAGE-$ELASTICSEARCH_SPACE_USED))

if [ $ELASTICSEARCH_SPACE_AVAILABLE -lt 10 ]; then

    echo "Elasticsearch is running out of disk space. Available space is less than 10GB."



    # Check when was the last Elasticsearch backup taken

    LAST_BACKUP=$(aws s3 ls s3://$S3_BUCKET_NAME/ --recursive | sort | tail -n 1 | awk '{print $1}')

    if [ -z "$LAST_BACKUP" ]; then

        echo "No backups found in the S3 bucket."

    else

        echo "The last Elasticsearch backup was taken on $LAST_BACKUP."

    fi

fi