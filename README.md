# knowing-scratch-image

Many know the [Scratch](https://hub.docker.com/_/scratch) image, but few know the details and tricks to use it correctly.

The objective of the repository is to show, through commands, the mysteries the Scratch image keeps. You can find this image on Docker Hub.

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

## Interesting commands output

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

[regctl](https://github.com/regclient/regclient) will help you to interact with container registries. This command has the same output as `docker scan`.

```
regctl manifest get scratch
```

<details>
  <summary>Output</summary>

  ```
  failed to get manifest docker.io/library/scratch:latest: request failed: not found [http 404]: {"errors": {"code":"MANIFEST_UNKNOWN","message":"manifest unknown","detail":"unknown tag=latest"}]}
  ```
</details>

## Create your image from scratch

Use the `Dockerfile-simple` file to build a new image from scratch. The new image will be really small.

```
docker image build \
  --file Dockerfile-simple \
  --progress plain \
  --tag knowing-scratch-image \
  .
```

<details>
  <summary>Output</summary>

  ```
  #1 [internal] load build definition from Dockerfile-simple
  #1 sha256:c2b14c6c81e91084d4a6a31f519054a313c4a2f0419c7e5dd526cf5efdee0691
  #1 transferring dockerfile: 44B done
  #1 DONE 0.0s

  #2 [internal] load .dockerignore
  #2 sha256:b4743841e7ace600972aa5913c0114df86bd4e80ce06da58a62c4b6187a4f73e
  #2 transferring context: 2B done
  #2 DONE 0.0s

  #3 [internal] load metadata for docker.io/library/golang:1.18.1
  #3 sha256:12b03ca396919374cac1f2bb4a1c46c80c15f6cef6eb69f217f095455132c948
  #3 DONE 0.0s

  #4 [builder 1/4] FROM docker.io/library/golang:1.18.1
  #4 sha256:4ad06f069bd7e52d9fe9fb6d39bd478fa15fb210df73b45129c8c5233652c3b2
  #4 DONE 0.0s

  #5 [builder 2/4] WORKDIR /app
  #5 sha256:87fccf2b991e137e524160caa53ff94def5eb942a93f59c0e5c16f1ec417405c
  #5 CACHED

  #6 [internal] load build context
  #6 sha256:a8e83eb1e8a1eaae9ab2ad4c6e55459829e992ed2020a7ea5df4445eac76611c
  #6 transferring context: 3.52kB done
  #6 DONE 0.0s

  #7 [builder 3/4] COPY . .
  #7 sha256:89d57ce88fbeab051fd8f8404cec9f651796cd4913c9a9b4278224dcff798dc6
  #7 DONE 0.0s

  #8 [builder 4/4] RUN CGO_ENABLED=0 go build -o /go/bin/app .
  #8 sha256:d97b9de6adeece92705a3f75d8c29a4a12848b46c728b69352513e547aaa982a
  #8 DONE 0.2s

  #9 [stage-1 1/1] COPY --from=builder /go/bin/app /app
  #9 sha256:f966d14202f622dd1b88724a3c29cd0e39b6a814a317e27977f7fa715d482333
  #9 DONE 0.0s

  #10 exporting to image
  #10 sha256:e8c613e07b0b7ff33893b694f7759a10d42e180f2b4dc349fb57dc6b71dcab00
  #10 exporting layers done
  #10 writing image sha256:1dfd3056e96d552eb5b5825eb5c2e52e52ec96829755b21a4c787607aeddf07f done
  #10 naming to docker.io/library/knowing-scratch-image done
  #10 DONE 0.0s
  ```
</details>

List the new image to know the size. Try to have an image smaller than this one :)

```
docker image ls knowing-scratch-image
```

<details>
  <summary>Output</summary>

  ```
  REPOSITORY              TAG       IMAGE ID       CREATED              SIZE
  knowing-scratch-image   latest    1dfd3056e96d   About a minute ago   1.81MB
  ```
</details>

Run the image created to know if works.

```
docker container run --rm knowing-scratch-image
```

<details>
  <summary>Output</summary>

  ```
  I'm running from scratch.
  I'm running from scratch.
  I'm running from scratch.
  ```
</details>

## Image layers behavior

The first layer in your new image will be made by the `COPY` instruction from the `Dockerfile-simple`. There isn't a reference to the `scratch` image in the `history` command, this is another peculiarity of this image.

```
docker image history knowing-scratch-image \
  --format 'table {{.CreatedBy}}\t{{.Size}}'
```

<details>
  <summary>Output</summary>

  ```
  CREATED BY                         SIZE
  ENTRYPOINT ["/app"]                0B
  COPY /go/bin/app /app # buildkit   1.81MB
  ```
</details>
