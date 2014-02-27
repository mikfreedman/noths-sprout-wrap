function assumed() {
  git ls-files -v | grep ^h | cut -c 3-
  if [ -f `brew --prefix`/etc/bash_completion ]; then
      . `brew --prefix`/etc/bash_completion
  fi
}
