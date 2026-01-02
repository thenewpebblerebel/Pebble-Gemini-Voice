FROM python:3.7-slim

ENV VENV=/opt/venv

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential git curl ca-certificates \
 && python -m venv $VENV \
 && $VENV/bin/python -m pip install --upgrade pip setuptools wheel \
 && mkdir -p /tmp/build /tmp/wheels
# Copy vendor patch scripts and wheel builder, then build patched wheels
COPY tmp/vendor /tmp/vendor
COPY scripts/build_wheels.sh /tmp/build_wheels.sh
RUN chmod +x /tmp/build_wheels.sh
RUN /tmp/build_wheels.sh

# Install built wheels first to avoid pip building legacy packages
RUN $VENV/bin/python -m pip install /tmp/wheels/*.whl || true

# Install pebble-tool (let pip resolve remaining deps using local wheels)
RUN $VENV/bin/python -m pip install --no-cache-dir git+https://github.com/pebble/pebble-tool.git

ENV PATH="$VENV/bin:$PATH"

WORKDIR /src
ENTRYPOINT ["/bin/bash"]
