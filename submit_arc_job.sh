#!/bin/bash

# Define params
export AWS_DEFAULT_REGION=us-east-1
export EKSCLUSTERNAME=eks-cluster
export EMRCLUSTERNAME=emr-on-$EKSCLUSTERNAME
export ROLENAME=${EMRCLUSTERNAME}-execution-role

#submit test job
export EMRCLUSTERID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name == 'emr-on-eks-ec2' && state == 'RUNNING'].id" --output text)
export ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)
export ROLEARN=arn:aws:iam::$ACCOUNTID:role/$ROLENAME
export OUTPUTS3BUCKET=${EMRCLUSTERNAME}-${ACCOUNTID}

# update aws CLI to the latest version (we will require aws cli version >= 2.1.14)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" 
unzip -q -o /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update

# create S3 bucket for output
aws s3api create-bucket --bucket $OUTPUTS3BUCKET

# sumbit job

aws emr-containers start-job-run --virtual-cluster-id $EMRCLUSTERID \
    --name arc-job --execution-role-arn $ROLEARN --release-label emr-6.2.0-latest \
    --job-driver '{"sparkSubmitJobDriver": {"entryPoint": "https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/arc_2.12-3.6.2.jar", "entryPointArguments":["--etl.config.uri=https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/green_taxi_load.ipynb"], "sparkSubmitParameters": "--packages com.typesafe:config:1.4.0 --class ai.tripl.arc.ARC --conf spark.executor.instances=6 --conf spark.executor.memory=4G --conf spark.driver.memory=2G --conf spark.executor.cores=2 --conf spark.kubernetes.driverEnv.OUTPUT=s3://'$OUTPUTS3BUCKET'/output/ --conf spark.kubernetes.driverEnv.SCHEMA=https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/green_taxi_schema.json"}}' \
    --configuration-overrides '{"monitoringConfiguration": {"cloudWatchMonitoringConfiguration": {"logGroupName": "/aws/eks/'$EKSCLUSTERNAME'/jobs", "logStreamNamePrefix": "arc-job"}}}'

echo "Done, navigate to https://s3.console.aws.amazon.com/s3/buckets/${OUTPUTS3BUCKET}"