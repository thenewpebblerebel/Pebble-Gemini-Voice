FROM bboehmke/pebble-dev

USER root

# Create a dummy project to trigger SDK unpacking, then patch the memory reporter
RUN mkdir -p /tmp/dummy-project && \
    cd /tmp/dummy-project && \
    echo '{"name":"dummy","version":"1.0.0","pebble":{"sdkVersion":"3","targetPlatforms":["basalt"],"capabilities":[],"messageKeys":{}}}' > package.json && \
    mkdir -p src/c && \
    echo '#include <pebble.h>\nvoid handle_init(void){}\nvoid handle_deinit(void){}\nint main(void){handle_init();app_event_loop();handle_deinit();}' > src/c/main.c && \
    echo 'def options(ctx):\n    ctx.load("pebble_sdk")\ndef configure(ctx):\n    ctx.load("pebble_sdk")\ndef build(ctx):\n    ctx.load("pebble_sdk")\n    ctx.pbl_program(source=ctx.path.ant_glob("src/**/*.c"), target="pebble-app.elf")\n    ctx.pbl_bundle(elf="pebble-app.elf")' > wscript && \
    su - pebble -c "cd /tmp/dummy-project && pebble build || true" && \
    find /home/pebble/.pebble-sdk -name 'report_memory_usage.py' -exec sed -i '39,60d' {} \; && \
    rm -rf /tmp/dummy-project

USER pebble

# Set working directory
WORKDIR /pebble

CMD ["pebble", "build"]
