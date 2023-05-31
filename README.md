# Runing Selenium Slides With CI

This is a POC concept for runing the no code web browser testing automation tool i.e. selenium side within ci.

## What is Selenium IDE how does it helps ?
Selenium IDE is a record and playback tools (browser extension), that is used to record the interaction we do with the webpages on browser. After recording the every interaction with the web page, it generates a file with `.side` extension which can be ran using the node library `selenium-side-runner`

- [Selenium IDE ](https://www.selenium.dev/selenium-ide/)
- [Side Runner NPM](https://www.npmjs.com/package/selenium-side-runner)

**Tools:**
- Selenium Web Driver
- Node Runtime
- Selenium IDE side


**docker_compose**

```yml
version: '3'

services:
  web:
    container_name: react_frontend
    build:
      context: .
      dockerfile: Dockerfile.Frontend
    command: "yarn start"

  selenium:
    image: selenium/standalone-chrome
    container_name: selenium_driver
    ports:
      - 4444:4444

  runner:
    container_name: slide_runner
    volumes:
      - ./scripts:/app/scripts
      - ./sides:/app/sides
    build:
      context: .
      dockerfile: Dockerfile.Runner
    depends_on:
      - web
      - selenium
    command: "sh scripts/run_test.sh"

```

- Frontend built in react.
- Sides placed inside `/sides` directory
- To run those sides on a browser environment, we need access to the browser which is handled by `selenium` service in docker.

**test script**

```sh
#!/bin/bash

wait_for_it() {
    local host="$1"
    local port="$2"

    while ! nc -z "$host" "$port"; do
        echo "$host:$port is not runing, waiting for it."
        sleep 0.1
    done
}

# container name and corresponding ports that should be waited for.
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
```

- So the idea is to wait untill all our subsystems (backend, frontend and other) containers to be started.
- And wait untill selenium service starts.
- Run the test


## Usage

Since this is a POC repo, for your project, the template would looke like below:

**docker-compose**

```yml
version: '3'

services:
  service1:
    container_name: <service1>
    build:
      context: .
      dockerfile: Dockerfile.<service1>
    command: "<command>"

  service2:
    container_name: <service2>
    build:
      context: .
      dockerfile: Dockerfile.<service2>
    command: "<command>"

  selenium:
    image: selenium/standalone-chrome
    container_name: selenium_driver
    ports:
      - 4444:4444

  runner:
    container_name: slide_runner
    volumes:
      - ./scripts:/app/scripts
      - ./sides:/app/sides
    build:
      context: .
      dockerfile: Dockerfile.Runner
    depends_on:
      - web
      - selenium
    command: "sh scripts/run_test.sh"
```

**run_test.sh**

```sh
#!/bin/bash

wait_for_it() {
    local host="$1"
    local port="$2"

    while ! nc -z "$host" "$port"; do
        echo "$host:$port is not runing, waiting for it."
        sleep 0.1
    done
}

# container name and corresponding ports that should be waited for.
wait_for_it "selenium_driver" "4444"
wait_for_it "<service1_container_name>" "<service1_container_port>"
wait_for_it "<service2_container_name>" "<service2_container_port>"
# .....
wait_for_it "<servicen_container_name>" "<servicen_container_port>"

echo "both services started"

slides_directory="sides"

for file in "$slides_directory"/*
do
    if [ -f "$file" ]; then
        echo "Runing slides from $file"
        selenium-side-runner "$file" --server http://selenium_driver:4444/wd/hub
    fi
done
```
