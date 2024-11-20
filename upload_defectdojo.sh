#!/bin/bash

# Default values for the variables
API_KEY=""
DOJO_URL=""
PRODUCT_ID=""
ENGAGEMENT_ID=""
SCAN_TYPE=""
FILE_PATH=""
PRODUCT_NAME=""
ENGAGEMENT_NAME=""

# Function to display help message
usage() {
    echo "Usage: $0 -api <api-key> -url <url> -product-id <product-id> -engagement-id <engagement-id> -scan-type <scan-type> -engagement_name <engagement-name> -file-path <file-path> -product-id <product-id> -engagement-id <engagement-id> -product-name <product-name>"
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -api) API_KEY="$2"; shift ;;
        -url) DOJO_URL="$2"; shift ;;
        -product-id) PRODUCT_ID="$2"; shift ;;
        -engagement_id) ENGAGEMENT_ID="$2"; shift;;
        -scan-type) SCAN_TYPE="$2"; shift ;;
        -engagement_name) ENGAGEMENT_NAME="$2"; shift ;;
        -file-path) FILE_PATH="$2"; shift ;;
        -product-id) PRODUCT_ID="$2"; shift ;;
        -engagement-id) ENGAGEMENT_ID="$2"; shift ;;
        -product-name) PRODUCT_NAME="$2"; shift ;;
        -h|--help) usage ;; # Display help
        *) echo "Unknown parameter: $1"; usage ;; # Handle unknown parameters
    esac
    shift
done
check_existing_test_by_type() {
   echo "Checking for existing tests of type: $SCAN_TYPE for engagement $ENGAGEMENT_ID..."
   RESPONSE=$(curl -X GET --header "Authorization: Token $API_KEY" $DOJO_URL/api/v2/tests/?engagement=$ENGAGEMENT_ID | jq -r '[.results[].scan_type] | join(",")')
   IFS=',' read -ra SCAN_TYPES <<< "$RESPONSE"
   for scan_type in "${SCAN_TYPES[@]}"; do
     if [ "$SCAN_TYPE" == "$scan_type" ]; then
        return 1
     fi
   done
   return 0
}

check_existing_test_by_type
if [ $? -eq 1 ];then
  curl -X POST --header "Content-Type: multipart/form-data" --header "Authorization: Token $API_KEY" -F "product_id=$PRODUCT_ID" -F "product_name=$PRODUCT_NAME" -F "engagement=$ENGAGEMENT_ID" -F "active=true"  -F "engagement_name=$ENGAGEMENT_NAME" -F "scan_type=$SCAN_TYPE" -F "file=@$FILE_PATH"  "$DOJO_URL/api/v2/reimport-scan/"
else
  curl -X POST --header "Content-Type: multipart/form-data" --header "Authorization: Token $API_KEY" -F "product_id=$PRODUCT_ID" -F "engagement=$ENGAGEMENT_ID"  -F "active=true" -F "product_name=$PRODUCT_NAME" -F "scan_type=$SCAN_TYPE"   -F "file=@$FILE_PATH" "$DOJO_URL/api/v2/import-scan/"
fi
