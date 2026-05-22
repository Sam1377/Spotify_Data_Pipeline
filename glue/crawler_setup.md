# AWS Glue Crawler — Setup Guide

This file documents how the Glue Crawler was configured to detect the schema
of the transformed S3 data and register it in the Glue Data Catalog.

---

## Crawler: `spotify-pipeline-crawler`

| Setting            | Value                                                        |
|--------------------|--------------------------------------------------------------|
| **Name**           | `spotify-pipeline-crawler`                                   |
| **Data store**     | S3                                                           |
| **S3 path**        | `s3://de-spotify-pipeline-1377/spotify-pipeline-transformed/`|
| **IAM Role**       | `AWSGlueServiceRole-spotify` (needs S3 read + Glue write)    |
| **Schedule**       | On demand (or daily after Airflow run)                       |
| **Output DB**      | `spotify` (created in Glue Data Catalog)                     |
| **Table prefix**   | `spotify_` (resulting table: `spotify_pipeline_transformed`) |

---

## IAM Policy for the Glue Role

Attach these managed policies to the Glue service role:

```
AWSGlueServiceRole
AmazonS3ReadOnlyAccess   (or a scoped inline policy for your bucket)
```

Inline policy scope (recommended):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::de-spotify-pipeline-1377",
        "arn:aws:s3:::de-spotify-pipeline-1377/*"
      ]
    }
  ]
}
```

---

## Detected Schema

After running the crawler, the table `spotify_spotify_pipeline_transformed`
will be created with the following columns:

| Column         | Type    | Notes                                  |
|----------------|---------|----------------------------------------|
| track_name     | string  |                                        |
| artist         | string  |                                        |
| album          | string  |                                        |
| popularity     | bigint  | 0–100                                  |
| duration_ms    | bigint  | Track length in milliseconds           |
| release_date   | string  | YYYY-MM-DD                             |
| duration_min   | double  | Computed by Airflow (duration_ms/60000)|
| processed_at   | string  | UTC timestamp added by Airflow         |

---

## Running the Crawler (AWS CLI)

```bash
# Start crawler
aws glue start-crawler --name spotify-pipeline-crawler --region ap-south-1

# Check status
aws glue get-crawler --name spotify-pipeline-crawler \
  --query 'Crawler.State' --region ap-south-1
```
