# knowing-scratch-image

Many know the [Scratch](https://hub.docker.com/_/scratch) image, but few know the details and tricks to use it correctly. The repository goal is to show, through commands, the mysteries the Scratch image keeps.

**Index**

* [Interesting commands output](#interesting-commands-output)
* [Create your image from scratch](#create-your-image-from-scratch)
* [Image layers behavior](#image-layers-behavior)
* [Access and debug images without shell](#access-and-debug-images-without-shell)
* [Setup user non-root](#setup-user-non-root)
* [References](#references)

Find this image on Docker Hub.

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

## Access and debug images without shell

When the image doesn't have installed `bash`, `sh`, or some other similar tool, you will not be able to access to the container to debug your application. This is the case for images built on top of the `scratch`.

Start a container from `knowing-scratch-image` image.

```
docker container run --detach knowing-scratch-image
```

<details>
  <summary>Output</summary>

  ```
  460764e65f7fb1b9f9d2a8c7c720f3919b494bfae17bb89d3b482d2698faa470
  ```
</details>

Then, try to access it

```
{
  CONTAINER_ID=$(docker container ls --latest --quiet)
  docker container exec -it $CONTAINER_ID bash
}
```

<details>
  <summary>Output</summary>

  ```
  OCI runtime exec failed: exec failed: container_linux.go:380: starting container process caused: exec: "bash": executable file not found in $PATH: unknown
  ```
</details>

To solve this problem you'll need a second image with the tools to debug your app installed. Also, the container started from the second image must use the parameter `pid` to access to the process running by the image `knowing-scratch-image`.

```
docker container run --rm -it --pid container:$CONTAINER_ID ubuntu
```

<details>
  <summary>Output</summary>

  ```
  root@3f165a273e85:/#
  ```
</details>

Once inside, you can do whatever you want with the app running from `scratch`

```
ps aux
```

<details>
  <summary>Output</summary>

  ```
  USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
  root         1  0.0  0.1 702748  1100 ?        Ssl  11:00   0:00 /app    # <- app running form scratch with root user
  root        15  0.0  0.2   3744  2848 pts/0    Ss   11:13   0:00 bash
  root        23  0.0  0.2   5472  2280 pts/0    R+   11:15   0:00 ps aux
  ```
</details>

## Setup user non-root

No mather you built your image from scratch, you should run your app using a non-root user. This could be a problem because you don't have a command like `useradd` or `cat` to create it inside the `scratch` image.

The solution is create the non-user in a previous stage in the `Dockerfile`, then copy the `/etc/passwd` to the final image. Take a look to the `Dockerfile` present in this repository.

Build a new image using the same tag.

```
docker image build --no-cache \
  --progress plain \
  --tag knowing-scratch-image \
  .
```

<details>
  <summary>Output</summary>

  ```
  #1 [internal] load build definition from Dockerfile-simple
  #1 sha256:79fa311d8bb2ec9185262bea7224cc6304ea30164f12da55a306b97b5e3cb0ff
  #1 transferring dockerfile: 44B done
  #1 DONE 0.0s

  #2 [internal] load .dockerignore
  #2 sha256:ce74d9d623a0e8ae4354557a55e4b13fb026db376ae3c8d98429eede559a6459
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
  #6 sha256:abe3c6c51bd8c87b69744217697efd4440b4b1ec1cb5c7d3c80ee0cefa76af10
  #6 transferring context: 19.20kB 0.0s done
  #6 DONE 0.0s

  #7 [builder 3/4] COPY . .
  #7 sha256:78a15e767c03c3d002c32b07707ab5c863de692fd6bc06d7bf3530479f34e970
  #7 DONE 0.0s

  #8 [builder 4/4] RUN CGO_ENABLED=0 go build -o /go/bin/app .
  #8 sha256:b35b1357e470895f7c5ad3685dbfb6606b0b3cfc46e7b3af655aba59f5f49133
  #8 DONE 0.3s

  #9 [stage-1 1/1] COPY --from=builder /go/bin/app /app
  #9 sha256:4def9a678dc2affecfa87d1eaa595b52822b2e3d5d7b21cd3e2e13fc972a4277
  #9 DONE 0.0s

  #10 exporting to image
  #10 sha256:e8c613e07b0b7ff33893b694f7759a10d42e180f2b4dc349fb57dc6b71dcab00
  #10 exporting layers 0.0s done
  #10 writing image sha256:3fc7c254b5bd9074a2a58a69d9f80a492266d589b6267e2ca506ba14d0884f1f done
  #10 naming to docker.io/library/knowing-scratch-image done
  #10 DONE 0.0s
  ```
</details>

Run a container using the image built.

```
docker container run --detach knowing-scratch-image
```

<details>
  <summary>Output</summary>

  ```
  d6f930e1f595a96ca7377d692c0df4bf449eafb1de7ec7de9eb851da2235c8ee
  ```
</details>

Access the container using a second image and check the process.

```
{
  CONTAINER_ID=$(docker container ls --latest --quiet)
  docker container run --rm -it --pid container:$CONTAINER_ID ubuntu
}
```

<details>
  <summary>Output</summary>

  ```
  root@d6f930e1f595:/#
  ```
</details>

```
ps aux
```

<details>
  <summary>Output</summary>

  ```
  USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
  10001        1  0.0  0.1 702748  1168 ?        Ssl  11:48   0:00 /app  # <- app running form scratch with non-root user
  root         9  0.0  0.2   3744  2992 pts/0    Ss   11:48   0:00 bash
  root        17  0.0  0.2   5472  2276 pts/0    R+   11:48   0:00 ps aux
  ```
</details>

## References

* [Inside Docker's "FROM scratch"](https://www.mgasch.com/2017/11/scratch/#how-to-access-the-scratch-container-on-osx-or-if-your-docker-engine-host-runs-on-a-remote-machine)
* [Why Can't I Pull The Scratch Docker Image?](https://mannes.tech/docker-scratch/)
* [Non-privileged containers based on the scratch image](https://medium.com/@lizrice/non-privileged-containers-based-on-the-scratch-image-a80105d6d341)
