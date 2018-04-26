FROM debian:stretch

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME cuda-claymore-ethereum-dual.local
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Upgrade base system
RUN apt update \
    && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt update && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends install wget ca-certificates libcurl3 && rm -rf /var/lib/apt/lists/*

# Install binary
#
# https://bitcointalk.org/index.php?topic=1433925.0
# Go to Google Drive link
# Next to the download button, click on the dots and select share
# Insert ID in the link below
# 1V1SBbYntsRz6-OOjJ0T9uMK27YMjDV8F is "Claymore's Dual Ethereum+Decred_Siacoin_Lbry_Pascal_Blake2s_Keccak AMD+NVIDIA GPU Miner v11.7 - LINUX.tar.gz"
RUN mkdir /root/src \
    && wget "https://drive.google.com/uc?export=download&id=1V1SBbYntsRz6-OOjJ0T9uMK27YMjDV8F" -O /root/src/miner.tar.gz \
    && mkdir /root/claymore \
    && tar xvzf /root/src/miner.tar.gz --strip-components=1 -C /root/claymore/ \
    && chmod 0755 /root/ && chmod 0755 /root/claymore/ && chmod 0755 /root/claymore/ethdcrminer64 \
    && rm -rf /root/src/

# Workaround Claymore not finding libnvml
# Do not attempt to link in /usr/local/nvidia/lib64, it is dynamic mount by nvidia-docker
# but /root is also in LD_LIBRARY_PATH
RUN ln -sf /usr/local/nvidia/lib64/libnvidia-ml.so.1 /root/libnvidia-ml.so

# nvidia-container-runtime @ https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
# For libssl.so.1.0.0
ENV LD_LIBRARY_PATH /root:${LD_LIBRARY_PATH}
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
