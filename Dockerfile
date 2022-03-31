# syntax=docker/dockerfile:1

# Stage 1 - Build the toolchain
FROM ubuntu:20.04

ARG N64_INST=/usr/local
ENV N64_INST=${N64_INST}

# install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=US/Central \
    apt-get install -yq --no-install-recommends wget bzip2 \
    build-essential apt-utils autoconf automake zlib1g-dev \
    bison flex texinfo file ca-certificates libelf-dev
RUN apt-get clean

# Build
COPY ./build-toolchain.sh /tmp/
WORKDIR /tmp
RUN ./build-toolchain.sh

# Stage 2 - Prepare minimal image
FROM ubuntu:20.04
ARG N64_INST=/usr/local
ENV N64_INST=${N64_INST}
ENV PATH="${N64_INST}/bin:$PATH"

COPY --from=0 ${MIPSEL} ${MIPSEL}
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    gcc g++ make && \
    apt-get clean && \
    apt autoremove -yq
