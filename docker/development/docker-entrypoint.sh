#!/usr/bin/env bash
set -e
cd /workspace/enciclovida
if [ "${1:-}" = "bundle" ]; then
  if ! bundle check; then
    echo 'Faltan gemas. Instalando dependencias del Gemfile.lock...'
    bundle install --jobs 2 --retry 3
  fi
fi
if [ "${1:-}" = "bundle" ] && [ "${2:-}" = "exec" ] && [ "${3:-}" = "rails" ] && [ "${4:-}" = "server" ]; then
  rm -f tmp/pids/server.pid
fi
exec "$@"
