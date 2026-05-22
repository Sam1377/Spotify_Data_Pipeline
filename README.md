[README.md](https://github.com/user-attachments/files/28160921/README.md)
# 🎵 Spotify End-to-End Data Pipeline

A production-style data engineering project that extracts real-time music data
from the **Spotify India Featured Playlists**, processes it through a fully
automated AWS cloud pipeline, and visualises insights in a **Looker Studio**
dashboard.

---

## 🏗️ Architecture

<img width="1302" height="816" alt="Gemini_Generated_Image_59r7uq59r7uq59r7" src="https://github.com/user-attachments/assets/6d64ed3f-2f3c-414a-a4de-251969b04a18" />


## ⚙️ Tech Stack

| Layer           | Technology                     |
|-----------------|--------------------------------|
| Data Source     | Spotify Web API                |
| Extraction      | AWS Lambda (Python 3.13)       |
| Scheduling      | Amazon EventBridge / CloudWatch|
| Storage         | Amazon S3 (Data Lake)          |
| Orchestration   | Apache Airflow 2.9 (Docker)    |
| Schema Detection| AWS Glue Crawler               |
| Metadata Store  | AWS Glue Data Catalog          |
| Analytics       | Amazon Athena                  |
| Visualisation   | Looker Studio                  |
| Libraries       | Spotipy 2.23.0, Boto3 1.42.61  |

---

## 📁 Project Structure

```
spotify-pipeline/
├── lambda/
│   ├── lambda_function.py        ← Spotify extractor (deploys to AWS Lambda)
│   ├── requirements.txt          ← spotipy + boto3
│   └── deploy_lambda.sh          ← one-command deploy script
│
├── airflow-docker/
│   ├── docker-compose.yml        ← Airflow 2.9 (LocalExecutor + Postgres)
│   ├── .env.example              ← environment variable template
│   └── dags/
│       └── spotify_pipeline_dag.py ← transform DAG (single task)
│
├── athena/
│   └── queries.sql               ← 8 analytics queries
│
├── glue/
│   └── crawler_setup.md          ← schema + IAM setup guide
│
├── s3-data/
│   ├── raw/                      ← sample raw extract (186 tracks)
│   └── transformed/              ← sample transformed output
│
└── README.md
```

---

## 🔄 Pipeline Flow

1. **EventBridge** fires the cron `0 0 * * ? *` (daily at midnight UTC).
2. **AWS Lambda** authenticates with Spotify using Client Credentials,
   fetches India Featured Playlists (up to 10 playlists → ~186 tracks),
   deduplicates, and writes newline-delimited JSON to
   `s3://de-spotify-pipeline-1377/spotify-pipeline-raw/`.
3. **Apache Airflow** DAG `spotify_pipeline` (schedule `@daily`) reads every
   raw JSON file, adds `duration_min` and `processed_at` columns, and writes
   the enriched records to `s3://.../spotify-pipeline-transformed/`.
4. **AWS Glue Crawler** detects the schema of the transformed data and
   registers it in the **Glue Data Catalog** as
   `spotify_spotify_pipeline_transformed`.
5. **Amazon Athena** runs serverless SQL over the catalog table.
6. **Looker Studio** connects to Athena and renders live dashboards.

---

## 📊 Dashboard Insights

- Top artists by track count
- Most popular tracks
- Track duration analysis
- Release year trends
- Bollywood vs Hollywood comparison

---

## 🚀 Setup & Deployment

### Prerequisites

- AWS Account (Free Tier compatible)
- Spotify Developer Account → [developer.spotify.com](https://developer.spotify.com)
- Python 3.10+
- Docker Desktop

---

### 1. Clone the repository

```bash
git clone https://github.com/sahilballewar/spotify-pipeline.git
cd spotify-pipeline
```

---

### 2. Configure AWS credentials

```bash
aws configure
# enter: Access Key ID, Secret Key, region (ap-south-1), output (json)
```

---

### 3. Create S3 bucket

```bash
aws s3api create-bucket \
  --bucket de-spotify-pipeline-1377 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-object --bucket de-spotify-pipeline-1377 --key spotify-pipeline-raw/
aws s3api put-object --bucket de-spotify-pipeline-1377 --key spotify-pipeline-transformed/
```
<img width="1470" height="830" alt="Screenshot 2026-05-23 at 12 03 27 AM" src="https://github.com/user-attachments/assets/eac097ea-1e01-4842-b3b9-2d69bf47bc5a" />

---

### 4. Deploy Lambda function

```bash
cd lambda
bash deploy_lambda.sh
```

Set these **Environment Variables** in the Lambda console:

| Key                    | Value                        |
|------------------------|------------------------------|
| `SPOTIFY_CLIENT_ID`    | your Spotify app client ID   |
| `SPOTIFY_CLIENT_SECRET`| your Spotify app client secret|
| `S3_BUCKET`            | `de-spotify-pipeline-1377`   |
| `S3_PREFIX`            | `spotify-pipeline-raw`       |

<img width="1470" height="830" alt="Screenshot 2026-05-23 at 1 11 41 AM" src="https://github.com/user-attachments/assets/e751f6ca-2f65-4979-b823-35b8d0b370b1" />

---

### 5. Start Airflow

```bash
cd airflow-docker
cp .env.example .env          # fill in your credentials
docker compose up -d
```

Open [http://localhost:8080](http://localhost:8080) → login `admin / admin`

Set these **Airflow Variables** (Admin → Variables):

| Key                   | Value                            |
|-----------------------|----------------------------------|
| `S3_BUCKET`           | `de-spotify-pipeline-1377`       |
| `RAW_PREFIX`          | `spotify-pipeline-raw`           |
| `TRANSFORMED_PREFIX`  | `spotify-pipeline-transformed`   |
| `AWS_REGION`          | `ap-south-1`                     |

<img width="1470" height="830" alt="Screenshot 2026-05-22 at 3 19 39 PM" src="https://github.com/user-attachments/assets/41c5c7c9-75f3-4eaf-ab01-ab4ae23300fb" />

---

### 6. Set up Glue Crawler

Follow the guide in [`glue/crawler_setup.md`](glue/crawler_setup.md).

<img width="1470" height="830" alt="Screenshot 2026-05-21 at 3 18 34 PM" src="https://github.com/user-attachments/assets/b5f00bcb-9551-44e0-ac4a-adb005307b94" />

---

### 7. Run Athena queries

Open the Athena console → run the queries in [`athena/queries.sql`](athena/queries.sql).

<img width="1470" height="830" alt="Screenshot 2026-05-21 at 3 58 18 PM" src="https://github.com/user-attachments/assets/66ca9580-5462-40dc-8552-f4509c5b705a" />

---

## 💡 Key Learnings

- Serverless data extraction with AWS Lambda + Spotipy
- Data lake architecture with raw and transformed S3 zones
- Workflow orchestration with Apache Airflow DAGs
- Automatic schema detection with AWS Glue Crawler
- Serverless SQL analytics with Amazon Athena
- End-to-end pipeline monitoring and logging

---

## 👨‍💻 Author

**Sahil Ballewar**

- GitHub: [@sahilballewar](https://github.com/sahilballewar)
- LinkedIn: [Sahil Ballewar](https://linkedin.com/in/sahilballewar)

---

## ⭐ If you found this helpful, please star the repo!
