# docker-android-re
Android reverse engineering and analysis setup for Docker. Refer to [this blog post](https://davidebove.com/blog/?p=1403) for more.

The package contains the actual Dockerfile, a build script for building the image and a "decompile" script that is included in the image.
To start the container, you can run:

```
docker run -it --name android-re --rm -v "$PWD":/work dbof/android-re
```

Note that this mounts the current directory into the image. If you don't want this, remove the "-v ..." flag.
