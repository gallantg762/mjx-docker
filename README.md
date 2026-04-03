# mjx-docker

A Docker image for [mjx](https://github.com/mjx-project/mjx), a Japanese Mahjong (riichi mahjong) simulator built for AI research.

## Overview

mjx does not provide pre-built wheels that work reliably on modern systems. This image builds mjx from source with the necessary patches to work with current toolchains.

**Key fixes applied:**
- Uses apt-managed CMake 3.16 instead of pip-managed CMake 4.x (which breaks the c-ares dependency)
- Patches `setup.py` to add `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` for CMake compatibility
- Pins `protobuf==3.20.2` to match mjx requirements

## Requirements

- Linux x86_64
- Docker 20.10+

## Usage

### Pull from Docker Hub

```bash
docker pull gallantg762/mjx:latest
```

### Build from source

```bash
git clone https://github.com/gallantg762/mjx-docker.git
cd mjx-docker
docker build -t mjx:latest .
```

Initial build takes 20–40 minutes due to C++ compilation and dependency fetching (boost, gRPC).

### Run smoke test

```bash
docker run --rm mjx:latest
```

Expected output:
```
mjx import: OK
Game finished in N steps
Returns: {...}
mjx smoke test: OK
```

### Interactive shell

```bash
docker run --rm -it -v $(pwd)/scripts:/workspace/scripts mjx:latest bash
```

### Run a training script

```bash
docker run --rm \
  -v $(pwd)/scripts:/workspace/scripts \
  mjx:latest \
  python3 scripts/train.py
```

## Environment

| Component | Version |
|-----------|---------|
| Base image | ubuntu:20.04 |
| Python | 3.8 |
| CMake | 3.16 (apt) |
| protobuf | 3.20.2 |
| mjx commit | fcdac0e |

## Notes

- Once built, push the image to a registry to avoid rebuilding from scratch every time.
- The boost and gRPC libraries are fetched and compiled during build, which accounts for most of the build time.
- For a more actively maintained alternative, consider [RiichiEnv](https://github.com/smly/RiichiEnv), which offers a similar Gym-style API with Rust-based core and `pip install riichienv` support.

## License

MIT
