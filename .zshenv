# Documentation: https://github.com/tacgnol/zsh4doug/blob/master/README.md.
#
# Do not modify this file unless you know exactly what you are doing.
# It is strongly recommended to keep all shell customization and configuration
# (including exported environment variables such as PATH) in ~/.zshrc or in
# files sourced from ~/.zshrc. If you are certain that you must export some
# environment variables in ~/.zshenv, do it where indicated by comments below.

if [ -n "${ZSH_VERSION-}" ]; then
  # If you are certain that you must export some environment variables
  # in ~/.zshenv (see comments at the top!), do it here:
  #
  #   export GOPATH=$HOME/go
  #
  # Do not change anything else in this file.

  : ${ZDOTDIR:=~}
  setopt no_global_rcs
  [[ -o no_interactive && -z "${Z4D_BOOTSTRAPPING-}" ]] && return
  setopt no_rcs
  unset Z4D_BOOTSTRAPPING
fi

Z4D_URL="https://raw.githubusercontent.com/tacgnol/zsh4doug/master"
: "${Z4D:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4doug/master}"

umask o-w

if [ ! -e "$Z4D"/z4d.zsh ]; then
  mkdir -p -- "$Z4D" || return
  >&2 printf '\033[33mz4d\033[0m: fetching \033[4mz4d.zsh\033[0m\n'
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -- "$Z4D_URL"/z4d.zsh >"$Z4D"/z4d.zsh.$$ || return
  elif command -v wget >/dev/null 2>&1; then
    wget -O-   -- "$Z4D_URL"/z4d.zsh >"$Z4D"/z4d.zsh.$$ || return
  else
    >&2 printf '\033[33mz4d\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
    return 1
  fi
  mv -- "$Z4D"/z4d.zsh.$$ "$Z4D"/z4d.zsh || return
fi

. "$Z4D"/z4d.zsh || return

setopt rcs
