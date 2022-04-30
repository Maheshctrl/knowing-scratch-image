# knowing-scratch-image

Many know the [Scratch](https://hub.docker.com/_/scratch) image, but few know the details and tricks to use it correctly.

The objective of the repository is to show, through commands, the mysteries that the Scratch image keeps. You can find this image as an official record on Docker Hub.

```
docker search scratch --filter=is-official=true
```

<details>
  <summary>Output</summary>

  ```
  NAME DESCRIPTION STARS OFFICIAL AUTOMATED
  scratch an explicitly empty image, especially for bu... 819 [OK]
  ```
</details>

The description resumes perfectly what the image is and when should be used.

```
docker search  scratch \
  --filter=is-official=true \
  --format '{{ .Description }}' \
  --no-trunc
```

<details>
  <summary>Output</summary>

  ```
  an explicitly empty image, especially for building images "FROM scratch"
  ```
</details>

## Interesting command output

There are multiple commands in Docker that print funny messages when using the `scratch` image.

### image pull

You can't pull the `scratch` image, there isn't an image `scratch` stored in Docker Hub. This command confirm us it is an empty image.

```
docker image pull scratch
```

<details>
  <summary>Output</summary>

  ```
  Using default tag: latest
  Error response from daemon: 'scratch' is a reserved name
  ```
</details>

### image ls

You can use the `scratch` image as a base to build new images, but you can't list it. The `scratch` image isn't stored in your host either.

```
docker image ls scratch
```

<details>
  <summary>Output</summary>

  ```
  Using default tag: latest
  Error response from daemon: 'scratch' is a reserved name
  ```
</details>

### container run

You can't run a container directly from the `scratch` image.

```
docker container run scratch
```

<details>
  <summary>Output</summary>

  ```
  Unable to find image 'scratch:latest' locally
  docker: Error response from daemon: 'scratch' is a reserved name.
  See 'docker run --help'.
  ```
</details>

### scan

The scan command doesn't detect a manifest stored in Docker Hub for this image.

```
docker scan scratch
```

<details>
  <summary>Output</summary>

  ```
  manifest unknown
  ```
</details>

### regctl manifest

[regctl](https://github.com/regclient/regclient) will help you to interact with container registries. This command has the same output than `docker scan`.

```
regctl manifest get scratch
```

<details>
  <summary>Output</summary>

  ```
  failed to get manifest docker.io/library/scratch:latest: request failed: not found [http 404]: {"errors": {"code":"MANIFEST_UNKNOWN","message":"manifest unknown","detail":"unknown tag=latest"}]}
  ```
</details>
