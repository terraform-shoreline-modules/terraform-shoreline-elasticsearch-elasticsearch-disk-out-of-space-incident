
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Elasticsearch disk out of space incident.
---

In this type of incident, Elasticsearch, a search and analytics engine, has run out of disk space on a server instance. This can result in various issues such as slow performance, inability to index new data, and even system crashes. It is important to resolve this issue quickly to avoid further disruption to the system.

### Parameters
```shell
export ELASTICSEARCH_INSTANCE="PLACEHOLDER"

export ELASTICSEARCH_ENDPOINT="PLACEHOLDER"

export AWS_REGION="PLACEHOLDER"

export INDEX_NAME="PLACEHOLDER"

export S3_BUCKET_NAME="PLACEHOLDER"

export ELASTICSEARCH_DOMAIN_NAME="PLACEHOLDER"
```

## Debug

### 1. Verify disk usage on the Elasticsearch instance
```shell
ssh ${ELASTICSEARCH_INSTANCE} df -h
```

### 2. Identify largest directories on the Elasticsearch instance
```shell
ssh ${ELASTICSEARCH_INSTANCE} sudo du -h / | sort -rh | head -n 10
```

### 3. Check Elasticsearch logs for errors related to disk space
```shell
ssh ${ELASTICSEARCH_INSTANCE} sudo tail -f /var/log/elasticsearch/elasticsearch.log | grep "disk"
```

### 4. Check Elasticsearch cluster health
```shell
curl -X GET "${ELASTICSEARCH_ENDPOINT}/_cluster/health?pretty"
```

### 5. Check Elasticsearch cluster status
```shell
curl -X GET "${ELASTICSEARCH_ENDPOINT}/_cluster/stats?pretty"
```

### 6. Check Elasticsearch indices status
```shell
curl -X GET "${ELASTICSEARCH_ENDPOINT}/_cat/indices?v"
```

### 7. Check Elasticsearch shards status
```shell
curl -X GET "${ELASTICSEARCH_ENDPOINT}/_cat/shards?v"
```

### The Elasticsearch retention policy is not configured correctly, leading to excessive data storage.
```shell
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


```

### The Elasticsearch backups have not been performed as scheduled, leading to insufficient disk space.
```shell
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


```

## Repair

### Add more disk space to the Elasticsearch server to prevent future incidents of disk out of space.
```shell

```

### Implement a mechanism to automatically delete old Elasticsearch data that is no longer required.
```shell
bash

#!/bin/bash



# Set variables

ELASTICSEARCH_INDEX=${INDEX_NAME}

DAYS_TO_KEEP=${NUMBER_OF_DAYS_TO_KEEP_DATA}



# Delete old data

aws es delete-by-query \

    --index $ELASTICSEARCH_INDEX \

    --query '{"range": {"@timestamp": {"lt": "now-'$DAYS_TO_KEEP'd"}}}'


```

### Add more disk space to the Elasticsearch server to prevent future incidents of disk out of space.
```shell


#!/bin/bash

# Replace the ${INSTANCE_ID} and ${VOLUME_SIZE} with the appropriate values

INSTANCE_ID=${INSTANCE_ID}

VOLUME_SIZE=${VOLUME_SIZE}



# Stop the Elasticsearch service

sudo service elasticsearch stop



# Create a new EBS volume with the desired size

VOLUME_ID=$(aws ec2 create-volume --availability-zone $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) --size $VOLUME_SIZE --volume-type gp2 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=elasticsearch-volume}]' | jq -r '.VolumeId')



# Wait for the volume to be available

aws ec2 wait volume-available --volume-ids $VOLUME_ID



# Attach the new volume to the Elasticsearch instance

aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdf



# Wait for the volume to be attached

aws ec2 wait volume-in-use --volume-ids $VOLUME_ID



# Start the Elasticsearch service

sudo service elasticsearch start


```