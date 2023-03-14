#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sink="$ROOT/../substreams-sink-kv"
main() {
  cd "$ROOT" &> /dev/null

  while getopts "hbc" opt; do
    case $opt in
      h) usage && exit 0;;
      c) clean=true;;
      \?) usage_error "Invalid option: -$OPTARG";;
    esac
  done
  shift $((OPTIND-1))

  set -e

  if [[ "$clean" == "true" ]]; then
    echo "Cleaning up existing data"
    rm -rf badger_data.db
  fi

  dsn="${KV_DSN:-"badger3:///${ROOT}/badger_data.db"}"

  $sink inject \
    -e "${SUBSTREAMS_ENDPOINT:-"mainnet.eth.streamingfast.io:443"}" \
    ${dsn} \
    "${SUBSTREAMS_MANIFEST:-"https://github.com/streamingfast/substreams-eth-block-meta/releases/download/v0.4.0/substreams-eth-block-meta-v0.4.0.spkg"}" \
    "${SUBSTREAMS_MODULE:-"kv_out"}" \
    "$@"
}

main "$@"
