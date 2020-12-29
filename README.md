# Arc ETL framework on EMR on EKS.
AWS Launched [EMR on EKS](https://aws.amazon.com/emr/features/eks/) and this sample demonstrates an end-to-end process to provision an EKS cluster, execute a Spark ETL job defined as a [jupyter notebook](green_taxi_load.ipynb) using [Arc Framework](https://arc.tripl.ai/getting-started/).

# Instructions
1. Open AWS CloudShell in us-east-1: https://console.aws.amazon.com/cloudshell/home?region=us-east-1
2. Run the following command to provision a new EKS cluster `eks-cluster` backed by Fargate and build a virtual EMR cluster `emr-on-eks-cluster` 
    ```bash
    curl https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/provision.sh | bash
    ```
3. Once provisioning is complete (~10 min), run the following command to submit a new Spark job on the virtual EMR cluster:
    ```bash
    curl https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/submit_arc_job.sh | bash
    ```
    The sample job will create an output S3 bucket, load the [TLC green taxi trip records](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page) from `s3://nyc-tlc/trip*data/green_tripdata*.csv`, apply schema, convert it into Delta format and store it in the output S3 bucket.

    The job is defined as a [jupyter notebook green_taxi_load.ipynb](green_taxi_load.ipynb) using [Arc Framework](https://arc.tripl.ai/getting-started/) and the applied schema is defined in [green_taxi_schema.json](green_taxi_schema.json)

4. To clean up resources, run:
    ```bash
    curl https://raw.githubusercontent.com/iizotov/tripl-ai-arc-on-emr-on-eks/main/deprovision.sh | bash
    ```

That's it!
