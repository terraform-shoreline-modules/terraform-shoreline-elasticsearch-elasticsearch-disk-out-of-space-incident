

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