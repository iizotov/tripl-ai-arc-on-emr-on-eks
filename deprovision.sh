#!/bin/bash

# Define params
export AWS_DEFAULT_REGION=us-east-1
export EKSCLUSTERNAME=eks-cluster
export EMRCLUSTERNAME=emr-on-$EKSCLUSTERNAME
export ROLENAME=${EMRCLUSTERNAME}-execution-role

#submit test job
export EMRCLUSTERID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name == '${EMRCLUSTERNAME}' && state == 'RUNNING'].id" --output text)
export ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)
export ROLEARN=arn:aws:iam::$ACCOUNTID:role/$ROLENAME
export OUTPUTS3BUCKET=${EMRCLUSTERNAME}-${ACCOUNTID}
export POLICYARN=arn:aws:iam::$ACCOUNTID:policy/${ROLENAME}-policy

# update aws CLI to the latest version (we will require aws cli version >= 2.1.14)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" 
unzip -q -o /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update

# clean up resources
aws emr-containers delete-virtual-cluster --id $EMRCLUSTERID
eksctl delete cluster --name=$EKSCLUSTERNAME
aws iam detach-role-policy --role-name $ROLENAME --policy-arn $POLICYARN
aws iam delete-role --role-name $ROLENAME
aws iam delete-policy --policy-arn $POLICYARN
aws s3 rm s3://$OUTPUTS3BUCKET --recursive
aws s3api delete-bucket --bucket $OUTPUTS3BUCKET

