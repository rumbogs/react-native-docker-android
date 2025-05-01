# react-native-docker-android

Dockerfile for building a RN Android build

This is meant to streamline the developer workflow and onboarding without having to handle the messy initial environment setup.

Also works with podman.

### Usage

If you're using Github repos as dependencies the script needs Github access for it to pull the repos.

This is done by creating a Github personal access token and storing the provided user and token in a
GH_USER and GH_TOKEN env variables for the script to access.

### Notes

Using personal access tokens has several advantages to SSH:

- PAT offers fine-grained access to repos (read, write, single repos)
- SSH requires a couple of dependencies to be installed in the container which might cause issues and increases the image size
- SSH keys are invalidation is a bit more difficult than PAT

Be aware of project specific dependency setup, while building this I had a missing `.svgrrc` file which strips unsupported attributes
from svg files. The metro bundler goes through each import and recursively parses the files before bundling them. If it doesn't know how to
parse something it fails silently and seems to loops indefinitely causing a memory leak. This was very hard to debug, before knowing
what's causing this I tried increasing the memory of everything starting with the docker machine, the container, the node process, gradle etc.
with no luck. The only thing that worked was going inside the container and logging stuff out from the React Native and Metro node module until
I've noticed the error. Of course, Metro's missing error handling didn't help either.

I prefer mounting the necessary files in separate bind mounts instead of just copying everything to the container to keep things
lightweight and manageable.
Also I have to modify a few files at runtime (change GH deps from ssh to https, remove yarn dev deps since the production flag is not working
and we waste time installing them and updating gradle options) so these are mounted to `tmp` files so that they're not updated by reference.
