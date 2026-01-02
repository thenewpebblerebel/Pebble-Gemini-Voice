FROM python:3.7-slim

ENV VENV=/opt/venv

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential git curl ca-certificates \
 && python -m venv $VENV \
 && $VENV/bin/python -m pip install --upgrade pip setuptools wheel \
 && mkdir -p /tmp/build /tmp/wheels

# Patch and install pypng (removes use_2to3 which breaks modern setuptools)
RUN cd /tmp/build \
 && curl -sSLO https://files.pythonhosted.org/packages/source/p/pypng/pypng-0.0.17.tar.gz \
 && tar -xzf pypng-0.0.17.tar.gz \
 && cd pypng-0.0.17 \
 && sed -i "s/conf\['use_2to3'\] *= *True//" setup.py || true \
 && $VENV/bin/python -m pip wheel . -w /tmp/wheels \
 && $VENV/bin/python -m pip install /tmp/wheels/*.whl

# Install a modern pyserial as a substitute for legacy 2.7 (avoids 2to3 build hooks)
RUN $VENV/bin/python -m pip install pyserial==3.4

# Install pebble-tool without auto-resolving deps, then install compatible deps manually
RUN $VENV/bin/python -m pip install --no-cache-dir --no-deps git+https://github.com/pebble/pebble-tool.git
RUN $VENV/bin/python -m pip install libpebble2==0.0.26 httplib2==0.9.1 oauth2client==1.4.12 \
	progressbar2==2.7.3 pyasn1==0.1.8 pyasn1-modules==0.0.6 pyqrcode==1.1 requests==2.7.0 rsa==3.1.4

ENV PATH="$VENV/bin:$PATH"

WORKDIR /src
ENTRYPOINT ["/bin/bash"]
