default:
    @just --list

emsdk-init:
    #!/usr/bin/env bash
    set -e
    # https://github.com/emscripten-core/emsdk
    emsdk activate latest
    source "$(which emsdk)_env.sh"
    emcc() {
        "$EMSDK_PYTHON" "$EMSDK/upstream/emscripten/emcc.py" "$@"
    }
    emcc --version

build watch="":
    #!/usr/bin/env bash
    set -e
    just clean
    just emsdk-init
    if [ "{{ watch }}" = "watch" ]; then
        zig build --watch
    else
        zig build
    fi

clean:
    rm -rf ./zig-out

start:
    serve -l 3000

dev:
    # https://github.com/pvolok/mprocs
    @just emsdk-init
    mprocs "just build watch" "just start"
