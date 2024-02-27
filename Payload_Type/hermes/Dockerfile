FROM slyd0g/hermes:new_darling
# ## If you want to build the container yourself
# FROM debian:bookworm

# ## Mythic Args
# ARG CA_CERTIFICATE
# ARG NPM_REGISTRY
# ARG PYPI_INDEX
# ARG PYPI_INDEX_URL
# ARG DOCKER_REGSITRY_MIRROR
# ARG HTTP_PROXY
# ARG HTTPS_PROXY

# ## Set Darling prefix
# ENV DPREFIX=/tmp/overlay/.darling
# RUN mkdir -p /tmp/overlay

# ## Install Darling dependencies + Python3 for Mythic
# RUN export DEBIAN_FRONTEND=noninteractive; apt update -y && apt upgrade -y  && \
# apt install -y cmake automake clang-15 bison flex libfuse-dev libudev-dev \
# pkg-config libc6-dev-i386 gcc-multilib libcairo2-dev libgl1-mesa-dev curl \
# libglu1-mesa-dev libtiff5-dev libfreetype6-dev git git-lfs libelf-dev libxml2-dev \
# libegl1-mesa-dev libfontconfig1-dev libbsd-dev libxrandr-dev libxcursor-dev libgif-dev \
# libavutil-dev libpulse-dev libavformat-dev libavcodec-dev libswresample-dev libdbus-1-dev \
# libxkbfile-dev libssl-dev libstdc++-12-dev llvm-dev libcap2-bin fuse wget python3-pip python3-venv
# RUN pip install --break-system-packages --no-cache-dir --upgrade pip && \
#     pip install --break-system-packages --no-cache-dir mythic-container

# ## Install Darling
# RUN git clone -j8 --recursive https://github.com/darlinghq/darling.git

# WORKDIR /darling
# RUN git lfs install && \
#     git pull && \
#     git submodule update --init --recursive

# WORKDIR /darling/build
# RUN cmake -DTARGET_i386=OFF ..
# RUN make -j8
# RUN make -j8 install

# WORKDIR /
# RUN rm -rf /darling

# ## Install Command Line Tools for Xcode 13.2
# COPY ["CommandLineTools", "/usr/local/libexec/darling/Library/Developer/CommandLineTools"]

# ## Kick off Mythic container service
# WORKDIR /Mythic/