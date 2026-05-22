from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    "owner": "sahil",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

def transform_spotify_data():
    print("Reading raw JSON from S3, adding duration_min + processed_at, writing to transformed/")

with DAG(
    dag_id="spotify_pipeline",
    description="Spotify data pipeline",
    default_args=default_args,
    start_date=datetime(2026, 5, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    transform_task = PythonOperator(
        task_id="transform_spotify_data",
        python_callable=transform_spotify_data,
    )
