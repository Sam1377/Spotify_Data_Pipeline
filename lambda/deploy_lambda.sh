#!/usr/bin/env bash
# deploy_lambda.sh — package and deploy the Lambda function to AWS
# Usage: bash deploy_lambda.sh
# Requires: aws CLI configured with appropriate IAM permissions

set -e

FUNCTION_NAME="spotify-data-extractor"
REGION="ap-south-1"
PACKAGE_DIR="package"
ZIP_FILE="spotify_lambda.zip"

echo "📦  Installing dependencies into ./${PACKAGE_DIR}/ ..."
pip install -r requirements.txt --target ./${PACKAGE_DIR} --quiet

echo "🗜   Zipping package ..."
cd ${PACKAGE_DIR}
zip -r ../${ZIP_FILE} . --quiet
cd ..
zip -g ${ZIP_FILE} lambda_function.py

echo "🚀  Deploying to AWS Lambda (${FUNCTION_NAME}) ..."
aws lambda update-function-code \
  --function-name ${FUNCTION_NAME} \
  --zip-file fileb://${ZIP_FILE} \
  --region ${REGION}

echo "✅  Deployment complete!"

# Cleanup
rm -rf ${PACKAGE_DIR} ${ZIP_FILE}
echo "🧹  Cleaned up temp files."
