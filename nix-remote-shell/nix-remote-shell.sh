#! @runtimeShell@
# shellcheck shell=bash

if [ -x "@runtimeShell@" ]; then export SHELL="@runtimeShell@"; fi;

set -e
set -o pipefail
shopt -s inherit_errexit

export PATH=@path@:$PATH

# Parse the command line.
copyFlags=()
extraBuildFlags=()
flakeFlags=(--extra-experimental-features 'nix-command flakes')

# log the given argument to stderr
log() {
    echo "$@" >&2
}

if [ "$#" -lt 2 ]; then
    log "Usage: $0 flake targetHost [nix-build-flags...]"
    exit 1
fi

flake="$1"
shift 1

targetHost="$1"
shift 1

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      --use-substitutes|--substitute-on-destination|-s)
        copyFlags+=("-s")
        ;;
      -I|--max-jobs|-j|--cores|--builders|--log-format)
        j="$1"; shift 1
        extraBuildFlags+=("$i" "$j")
        ;;
      --accept-flake-config|-j*|--quiet|--print-build-logs|-L|--no-build-output|-Q| --show-trace|--keep-going|-k|--keep-failed|-K|--fallback|--refresh|--repair|--impure|--offline|--no-net)
        extraBuildFlags+=("$i")
        ;;
      --verbose|-v|-vv|-vvv|-vvvv|-vvvvv)
        verboseScript="true"
        extraBuildFlags+=("$i")
        ;;
      --option|--override-input)
        j="$1"; shift 1
        k="$1"; shift 1
        extraBuildFlags+=("$i" "$j" "$k")
        ;;
      *)
        log "$0: unknown option \`$i'"
        exit 1
        ;;
    esac
done

# log the given argument to stderr if verbose mode is on
logVerbose() {
    if [ -n "$verboseScript" ]; then
      echo "$@" >&2
    fi
}

# Run a command, logging it first if verbose mode is on
runCmd() {
    logVerbose "$" "$@"
    "$@"
}


build() {
    logVerbose "Building in flake mode."
    local attr="$1"
    shift 1
    local evalArgs=()
    local buildArgs=()
    local drv=

    while [ "$#" -gt 0 ]; do
        local i="$1"; shift 1
        case "$i" in
            --recreate-lock-file|--no-update-lock-file|--no-write-lock-file|--no-registries|--commit-lock-file)
            evalArgs+=("$i")
            ;;
            --update-input)
            local j="$1"; shift 1
            evalArgs+=("$i" "$j")
            ;;
            --override-input)
            local j="$1"; shift 1
            local k="$1"; shift 1
            evalArgs+=("$i" "$j" "$k")
            ;;
            --impure) # We don't want this in buildArgs, it's only needed at evaluation time, and unsupported during realisation
            ;;
            *)
            buildArgs+=("$i")
            ;;
        esac
    done

    drv="$(runCmd nix "${flakeFlags[@]}" eval --raw "${attr}.drvPath" "${evalArgs[@]}" "${extraBuildFlags[@]}")"
    if [ -a "$drv" ]; then
        logVerbose "Running nix with these NIX_SSHOPTS: $SSHOPTS"
        NIX_SSHOPTS=$SSHOPTS runCmd nix "${flakeFlags[@]}" copy "${copyFlags[@]}" --derivation --to "ssh://$targetHost" "$drv"
        path="$(ssh $SSHOPTS "$targetHost" nix-store -r "$drv" "${buildArgs[@]}")"
        runCmd ssh -t $SSHOPTS "$targetHost" nix shell "$path"
    else
        log "nix eval failed"
        exit 1
    fi
}

build "$flake" "${extraBuildFlags[@]}" 
