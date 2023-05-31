#!/bin/bash

wait_for_it() {
    local host="$1"
    local port="$2"

    while ! nc -z "$host" "$port"; do
        echo "$host:$port is not runing, waiting for it."
        sleep 0.1
    done
}

# containers names and port that should be waited for
wait_for_it "selenium_driver" "4444"
wait_for_it "react_frontend" "3000"

echo "both services started"

slides_directory="sides"

for file in "$slides_directory"/*
do
    if [ -f "$file" ]; then
        echo "Runing slides from $file"
        selenium-side-runner "$file" --server http://selenium_driver:4444/wd/hub
    fi
done

