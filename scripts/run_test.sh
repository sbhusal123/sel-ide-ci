#!/bin/bash

# wait untill selenium driver starts
while ! nc -z "selenium_driver" "4444"; do
    echo "Selenium driver is not started yet, waiting..."
    sleep 0.1
done

# wait untill frontend starts
while ! nc -z "react_frontend" "3000"; do
    echo "React frontend is not started yet, waiting..."
    sleep 0.1
done

echo "both services started"

selenium-side-runner Test.side --server http://selenium_driver:4444/wd/hub

exec "@"
