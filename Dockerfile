# Dockerfile for building mjx from source
# Base: Ubuntu 20.04 + Python 3.8 + apt-managed CMake 3.16
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.8 \
    python3.8-dev \
    python3-pip \
    python3.8-distutils \
    build-essential \
    cmake \
    ninja-build \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

RUN python3 -m pip install --upgrade pip setuptools wheel

WORKDIR /workspace

RUN git clone --recurse-submodules https://github.com/mjx-project/mjx.git

WORKDIR /workspace/mjx

RUN pip install --no-cache-dir \
    grpcio \
    grpcio-tools \
    "protobuf==3.20.2" \
    numpy

# Patch setup.py to add CMake compatibility flag
# Required because the c-ares dependency uses CMake syntax older than 3.5
RUN sed -i 's/cmake_args.append(f"-DMJX_BUILD_GRPC={build_grpc}")/cmake_args.append(f"-DMJX_BUILD_GRPC={build_grpc}")\n        cmake_args.append("-DCMAKE_POLICY_VERSION_MINIMUM=3.5")/' setup.py

# Verify patch
RUN grep "POLICY_VERSION" setup.py

# Use --no-build-isolation to prevent pip from installing cmake 4.x,
# which is incompatible with the c-ares dependency bundled in gRPC
RUN pip install --no-cache-dir --no-build-isolation .

WORKDIR /workspace
COPY smoke_test.py .

CMD ["python3", "smoke_test.py"]