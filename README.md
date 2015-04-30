# About

The `docker-registry-frontend` is a pure web-based solution for browsing and modifying a private Docker registry.

# Features

For a list of all the features, please see the [Wiki][features].

# Development

To learn how to develop for the docker-registry-frontend, see
[here](develop/README.md).

# Usage

This application is available in the form of a Docker image that you can run as a container by executing this command:

    sudo docker run \
      -d \
      -e ENV_DOCKER_REGISTRY_HOST=ENTER-YOUR-REGISTRY-HOST-HERE \
      -e ENV_DOCKER_REGISTRY_PORT=ENTER-PORT-TO-YOUR-REGISTRY-HOST-HERE \
      -p 8080:80 \
      b4mad/docker-registry-frontend

This command starts the container and forwards the container's private port `80` to your host's port `8080`. Make sure you specify the correct url to your registry.

When the application runs you can open your browser and navigate to [http://localhost:8080][1].

## Docker registry using SSL encryption

If the Docker registry is only reachable via HTTPs (e.g. if it sits behind a proxy) , you can run the following command:

    sudo docker run \
      -d \
      -e ENV_DOCKER_REGISTRY_HOST=ENTER-YOUR-REGISTRY-HOST-HERE \
      -e ENV_DOCKER_REGISTRY_PORT=ENTER-PORT-TO-YOUR-REGISTRY-HOST-HERE \
      -e ENV_DOCKER_REGISTRY_USE_SSL=1 \
      -p 8080:80 \
      b4mad/docker-registry-frontend

## SSL encryption

If you want to run the application with SSL enabled, you can do the following:

    sudo docker run \
      -d \
      -e ENV_DOCKER_REGISTRY_HOST=ENTER-YOUR-REGISTRY-HOST-HERE \
      -e ENV_DOCKER_REGISTRY_PORT=ENTER-PORT-TO-YOUR-REGISTRY-HOST-HERE \
      -e ENV_USE_SSL=yes \
      -v $PWD/server.crt:/etc/httpd/server.crt:ro \
      -v $PWD/server.key:/etc/httpd/server.key:ro \
      -p 443:443 \
      b4mad/docker-registry-frontend
    
Note that the application still serves the port `80` but it is simply not exposed ;). Enable it at your own will. When the application runs with SSL you can open your browser and navigate to [https://localhost][2].

## Use the application as the registry

If you are running the Docker registry on the same host as the application but only accessible to the application (eg. listening on `127.0.0.1`) then you can use the application as the registry itself.

Normally this would then give bad advice on how to access a tag:

    docker pull localhost:5000/yourname/imagename:latest

We can override what hostname and port to put here:

    sudo docker run \
     -d \
     -e ENV_DOCKER_REGISTRY_HOST=localhost \
     -e ENV_DOCKER_REGISTRY_PORT=5000 \
     -e ENV_REGISTRY_PROXY_FQDN=ENTER-YOUR-APPLICATION-HOST-HERE \
     -e ENV_REGISTRY_PROXY_PORT=ENTER-PORT-TO-YOUR-APPLICATION-HOST-HERE \
     -e ENV_USE_SSL=yes \
     -v $PWD/server.crt:/etc/httpd/server.crt:ro \
     -v $PWD/server.key:/etc/httpd/server.key:ro \
     -p 443:443 \
     b4mad/docker-registry-frontend

A value of `80` or `443` for `ENV_REGISTRY_PROXY_PORT` will not actually be shown as Docker will check `443` and then `80` by default.

# Browse mode

If you want to start applicaton with browse mode which means no repos/tags management feature in the UI, You can specify `ENV_MODE_BROWSE_ONLY` flag as follows:

    sudo docker run \
      -d \
      -e ENV_DOCKER_REGISTRY_HOST=ENTER-YOUR-REGISTRY-HOST-HERE \
      -e ENV_DOCKER_REGISTRY_PORT=ENTER-PORT-TO-YOUR-REGISTRY-HOST-HERE \
      -e ENV_MODE_BROWSE_ONLY=true \
      -p 8080:80 \
      b4mad/docker-registry-frontend

You can set `true` or `false` to this flag.

# TODO

## add Kerberos authentication again

I (goern) am pretty sure that this not works with CentOS7 at the moment.

## Test SSL mode

I (goern) have not tested the TLS mode very well.

## relocate certificates

We should relacate the certificates to some distribution agnostic place.


# Contributions are welcome!

If you like the application, I invite you to contribute and report bugs or feature request on the project's github page: [https://github.com/kwk/docker-registry-frontend][3].
To learn how to develop for the docker-registry-frontend, see [here](develop/README.md).

Thank you for your interest!

 -- Konrad


  [1]: http://localhost:8080
  [2]: https://localhost
  [3]: https://github.com/kwk/docker-registry-frontend
  [features]: https://github.com/kwk/docker-registry-frontend/wiki/Features
