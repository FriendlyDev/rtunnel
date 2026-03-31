# bash completion for rtunnel
# Source this from ~/.bashrc:
#   source /path/to/rtunnel.bash

_rtunnel_complete() {
  local cur prev words cword
  _init_completion -n : || return

  local cmds="open ls close history reopen forget name help --help --version"

  if [[ $cword -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
    return
  fi

  local sub="${words[1]}"

  case "$sub" in
    open)
      local opts="--local --remote --ssh --name --private --bind --help --version --"
      # If completing option values after --local/--remote/--ssh/--name/--bind, do nothing special.
      if [[ "$cur" == --* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return
      fi
      ;;
    close)
      # Suggest local ports from active dir if possible
      local dir="${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel/active"
      if [[ -d "$dir" ]]; then
        local ports
        ports="$(command ls -1 "$dir" 2>/dev/null | sed -n 's/\.tsv$//p' | tr '\n' ' ')"
        COMPREPLY=( $(compgen -W "$ports" -- "$cur") )
        return
      fi
      ;;
    *)
      ;;
  esac
}

# Uses bash-completion's helper if available
if declare -F _init_completion >/dev/null 2>&1; then
  complete -F _rtunnel_complete rtunnel
else
  # Fallback basic completion without bash-completion package
  complete -F _rtunnel_complete rtunnel
fi