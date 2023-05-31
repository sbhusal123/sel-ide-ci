#!/bin/bash

# Define the URL of the Docker container you want to monitor
WEB_CONTAINER_URL="http://web:3000"
SELENIUM_CONTAINER_URL="http://selenium:4444/wd/hub"

# Define the maximum number of retries
MAX_RETRIES=10

# Define the time interval between retries (in seconds)
RETRY_INTERVAL=5

# Function to check if the response code is 200
function check_response_code() {
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$1")
    if [ "$response_code" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Wait until the response code is 200 or maximum retries exceeded
retries=0
until check_response_code(WEB_CONTAINER_URL) || [ "$retries" -eq "$MAX_RETRIES" ]; do
    retries=$((retries+1))
    sleep "$RETRY_INTERVAL"
done

until check_response_code(SELENIUM_CONTAINER_URL) || [ "$retries" -eq "$MAX_RETRIES" ]; do
    retries=$((retries+1))
    sleep "$RETRY_INTERVAL"
done


selenium-side-runner Test.side --server http://selenium:4444/wd/hub
