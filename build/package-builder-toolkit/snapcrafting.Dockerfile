# Ubuntu 18.04 based image to match the core18 snap
FROM cimg/base:stable-18.04

LABEL maintainer="Andrei Jiroh <Ricardo@Feliciano.Tech>"

RUN sudo apt-get update && sudo apt-get install -y \
		snapd \
		squashfs-tools \
	&& \
	sudo rm -rf /var/lib/apt/lists/*

# Manually install the core snap, a dependency of the snapcraft snap
RUN curl -L $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/core" | jq ".download_url" -r) --output core.snap && \
	sudo mkdir -p /snap/core && \
	sudo unsquashfs -d /snap/core/current core.snap && \
	rm -f core.snap

# Manually install the core18 snap, the main point of this image
RUN curl -L $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/core18" | jq ".download_url" -r) --output core18.snap && \
	sudo mkdir -p /snap/core18 && \
	sudo unsquashfs -d /snap/core18/current core18.snap && \
	rm -f core18.snap

# Manually install the snapcraft snap, so we can use it to build new snaps
RUN curl -L $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=stable" | jq ".download_url" -r) --output snapcraft.snap && \
	sudo mkdir -p /snap/snapcraft && \
	sudo unsquashfs -d /snap/snapcraft/current snapcraft.snap && \
	rm -f snapcraft.snap

# Install the Snapcraft runner
COPY snapcraft-wrapper /snap/bin/snapcraft


# Set the proper environment
ENV PATH=/snap/bin:$PATH

# This run step is normally bad to have by itself however without it, users of 
# this image will need to manually run `apt-get update` before they can build 
# a majority of snaps. This increases build times which isn't good in CI.
# The echo statement allows us to break the cache for this step more easily 
# while also providing context.
RUN sudo apt-get update && echo "APT index last updated March 10, 2021 at the earliest."
