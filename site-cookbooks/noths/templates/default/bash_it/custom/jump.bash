export MARKPATH=$HOME/.marks

function jump {
cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
  }

function mark {
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
  rm -i "$MARKPATH/$1"
}

function marks {
  \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

_jump()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$( ls $MARKPATH )" -- $cur) )
}
complete -F _jump jump

function __git_ps1_temp {
local b="$(git symbolic-ref HEAD 2>/dev/null)";
if [ -n "$b" ]; then
  printf " %s " "${b##refs/heads/}";
fi
}
