#!/bin/bash

set -e

REGION="eu-north-1"
INSTANCE_ID="i-0af5b5777480d46e9"
SG_NAME="sg_web"

# Create security group
echo "creating new security group $SG_NAME and capturing id"
export SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description "allow 8080" --region $REGION --output text --query 'GroupId')

# Add ingress rule to security group
echo "adding ingress rule to security group $SG_NAME"
aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 8080 --cidr 0.0.0.0/0 --region $REGION --output text

#attach it to the above instance
echo "attaching security group $SG_NAME to instance $INSTANCE_ID"
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups $SG_ID --region $REGION --output text

echo "Done! with script, now you can run drift_detect.yml in githubactions"
