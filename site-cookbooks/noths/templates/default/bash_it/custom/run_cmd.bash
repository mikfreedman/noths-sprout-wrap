function run_cmd() {
  echo "Running $@"
  "$@"
  local error=$?
  if [ $error -ge 1 ]; then
    echo "[error] command exited with status code $error"
    errors=1

    return 1
  else
    return 0
  fi
}
