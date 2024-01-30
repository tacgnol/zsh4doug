if '[' '-z' "${ZSH_VERSION-}" ']' || ! 'eval' '[[ "$ZSH_VERSION" == (5.<8->*|<6->.*) ]]'; then
  '.' "$Z4D"/zsh4doug/sc/exec-zsh-i || 'return'
fi

if [[ -x /proc/self/exe ]]; then
  typeset -gr _z4d_exe=${${:-/proc/self/exe}:A}
else
  () {
    emulate zsh -o posix_argzero -c 'local exe=${0#-}'
    if [[ $SHELL == /* && ${SHELL:t} == $exe && -x $SHELL ]]; then
      exe=$SHELL
    elif (( $+commands[$exe] )); then
      exe=$commands[$exe]
    elif [[ -x $exe ]]; then
      exe=${exe:a}
    else
      print -Pru2 -- "%F{3}z4d%f: unable to find path to %F{1}zsh%f"
      return 1
    fi
    typeset -gr _z4d_exe=${exe:A}
  } || return
fi

if ! { zmodload -s zsh/terminfo zsh/zselect && [[ -n $^fpath/compinit(#qN) ]] ||
       [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4d_exe == */bin/zsh &&
          -e ${_z4d_exe:h:h}/share/zsh/5.8/scripts/relocate ]] }; then
  builtin source $Z4D/zsh4doug/sc/exec-zsh-i || return
fi

if [[ ! -o interactive ]]; then
  # print -Pru2 -- "%F{3}z4d%f: starting interactive %F{2}zsh%f"
  # This is caused by Z4D_BOOTSTRAPPING, so we don't need to consult ZSH_SCRIPT and the like.
  exec -- $_z4d_exe -i || return
fi

typeset -gr _z4d_opt='emulate -L zsh &&
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
  setopt no_prompt_bang no_bg_nice no_aliases'

zmodload zsh/{datetime,langinfo,parameter,system,terminfo,zutil} || return
zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm,zf_rmdir,zf_ln}    || return
zmodload -F zsh/stat b:zstat                                     || return

() {
  if [[ $1 != $Z4D/zsh4doug/main.zsh ]]; then
    print -Pru2 -- "%F{3}z4d%f: confusing %Umain.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi
  if (( _z4d_zle )); then
    typeset -gr _z4d_param_pat=$'ZDOTDIR=$ZDOTDIR\0Z4D=$Z4D\0Z4D_URL=$Z4D_URL'
    typeset -gr _z4d_param_sig=${(e)_z4d_param_pat}
    function -z4d-check-core-params() {
      [[ "${(e)_z4d_param_pat}" == "$_z4d_param_sig" ]] || {
        -z4d-error-param-changed
        return 1
      }
    }
  else
    function -z4d-check-core-params() {}
  fi
} ${${(%):-%x}:a} || return

export -T MANPATH=${MANPATH:-:} manpath
export -T INFOPATH=${INFOPATH:-:} infopath
typeset -gaU cdpath fpath mailpath path manpath infopath

function -z4d-init-homebrew() {
  (( ARGC )) || return 0
  local dir=${1:h:h}
  export HOMEBREW_PREFIX=$dir
  export HOMEBREW_CELLAR=$dir/Cellar
  if [[ -e $dir/Homebrew/Library ]]; then
    export HOMEBREW_REPOSITORY=$dir/Homebrew
  else
    export HOMEBREW_REPOSITORY=$dir
  fi
}

if [[ $OSTYPE == darwin* ]]; then
  if [[ ! -e $Z4D/cache/init-darwin-paths ]] || ! source $Z4D/cache/init-darwin-paths; then
    autoload -Uz $Z4D/zsh4doug/fn/-z4d-gen-init-darwin-paths
    -z4d-gen-init-darwin-paths && source $Z4D/cache/init-darwin-paths
  fi
  [[ -z $HOMEBREW_PREFIX ]] && -z4d-init-homebrew {/opt/homebrew,/usr/local}/bin/brew(N)
elif [[ $OSTYPE == linux* && -z $HOMEBREW_PREFIX ]]; then
  -z4d-init-homebrew {/home/linuxbrew/.linuxbrew,~/.linuxbrew}/bin/brew(N)
fi

fpath=(
  ${^${(M)fpath:#*/$ZSH_VERSION/functions}/%$ZSH_VERSION\/functions/site-functions}(-/N)
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(-/N)
  /opt/homebrew/share/zsh/site-functions(-/N)
  /usr{/local,}/share/zsh/{site-functions,vendor-completions}(-/N)
  $fpath
  $Z4D/zsh4doug/fn)

autoload -Uz -- $Z4D/zsh4doug/fn/(|-|_)z4d[^.]#(:t) || return
functions -Ms _z4d_err

path+=($Z4D/fzf/bin)
manpath=($manpath $Z4D/fzf/man '')

() {
  path=(${@:|path} $path /snap/bin(-/N))
} {~/bin,~/.local/bin,~/.cargo/bin,${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin},${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin},/opt/local/sbin,/opt/local/bin,/usr/local/sbin,/usr/local/bin}(-/N)

() {
  manpath=(${@:|manpath} $manpath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/man},/opt/local/share/man}(-/N)

() {
  infopath=(${@:|infopath} $infopath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/info},/opt/local/share/info}(-/N)

if [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4d_exe == */bin/zsh &&
      -e ${_z4d_exe:h:h}/share/zsh/5.8/scripts/relocate ]]; then
  if [[ $TERMINFO != ~/.terminfo && $TERMINFO != ${_z4d_exe:h:h}/share/terminfo &&
        -e ${_z4d_exe:h:h}/share/terminfo/$TERM[1]/$TERM ]]; then
    export TERMINFO=${_z4d_exe:h:h}/share/terminfo
  fi
  if [[ -e ${_z4d_exe:h:h}/share/man ]]; then
    manpath=(${_z4d_exe:h:h}/share/man $manpath '')
  fi
fi

: ${GITSTATUS_CACHE_DIR=$Z4D/cache/gitstatus}
: ${ZSH=$Z4D/ohmyzsh/ohmyzsh}
: ${ZSH_CUSTOM=$Z4D/ohmyzsh/ohmyzsh/custom}
: ${ZSH_CACHE_DIR=$Z4D/cache/ohmyzsh}

[[ $terminfo[Tc] == yes && -z $COLORTERM ]] && export COLORTERM=truecolor

if [[ $EUID == 0 && -z ~(#qNU) && $Z4D == ~/* ]]; then
  typeset -gri _z4d_dangerous_root=1
else
  typeset -gri _z4d_dangerous_root=0
fi

[[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]] || -z4d-fix-locale

function -z4d-cmd-source() {
  local _z4d_file _z4d_compile
  zparseopts -D -F -- c=_z4d_compile -compile=_z4d_compile || return '_z4d_err()'
  emulate zsh -o extended_glob -c 'local _z4d_files=(${^${(M)@:#/*}}(N) $Z4D/${^${@:#/*}}(N))'
  if (( ${#_z4d_compile} )); then
    builtin set --
    for _z4d_file in "${_z4d_files[@]}"; do
      -z4d-compile "$_z4d_file" || true
      builtin source -- "$_z4d_file"
    done
  else
    emulate zsh -o extended_glob -c 'local _z4d_rm=(${^${(@)_z4d_files:#$Z4D/*}}.zwc(N))'
    (( ! ${#_z4d_rm} )) || zf_rm -f -- "${_z4d_rm[@]}" || true
    builtin set --
    for _z4d_file in "${_z4d_files[@]}"; do
      builtin source -- "$_z4d_file"
    done
  fi
}

function -z4d-cmd-load() {
  local -a compile
  zparseopts -D -F -- c=compile -compile=compile || return '_z4d_err()'

  local -a files

  () {
    emulate -L zsh -o extended_glob
    local pkgs=(${(M)@:#/*} $Z4D/${^${@:#/*}})
    pkgs=(${^${(u)pkgs}}(-/FN))
    local dirs=(${^pkgs}/functions(-/FN))
    local funcs=(${^dirs}/^([_.]*|prompt_*_setup|README*|*~|*.zwc)(-.N:t))
    fpath+=($pkgs $dirs)
    (( $#funcs )) && autoload -Uz -- $funcs
    local dir
    for dir in $pkgs; do
      if [[ -s $dir/init.zsh ]]; then
        files+=($dir/init.zsh)
      elif [[ -s $dir/${dir:t}.plugin.zsh ]]; then
        files+=($dir/${dir:t}.plugin.zsh)
      fi
    done
  } "$@"

  -z4d-cmd-source "${compile[@]}" -- "${files[@]}"
}

function -z4d-cmd-init() {
  if (( ARGC )); then
    print -ru2 -- ${(%):-"%F{3}z4d%f: unexpected %F{1}init%f argument"}
    return '_z4d_err()'
  fi
  if (( ${+_z4d_init_called} )); then
    if [[ ${funcfiletrace[-1]} != zsh:0 ]]; then
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' '\033[33mz4d\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshrc\033[0m\n'
      else
        >&2 'printf' '\033[33mz4d\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n'
      fi
      'return' '1'
    fi
    print -ru2 -- ${(%):-"%F{3}z4d%f: %F{1}init%f cannot be called more than once"}
    return '_z4d_err()'
  fi
  -z4d-check-core-params || return
  typeset -gri _z4d_init_called=1

  () {
    eval "$_z4d_opt"

    (( _z4d_dangerous_root || $+Z4D_SSH ))                                                   ||
      ! zstyle -T :z4d: chsh                                                                 ||
      [[ ${SHELL-} == $_z4d_exe || ${SHELL-} -ef $_z4d_exe || -e $Z4D/stickycache/no-chsh ]] ||
      -z4d-chsh                                                                              ||
      true

    local -a start_tmux
    local -i install_tmux need_restart
    if [[ -n $MC_TMPDIR ]]; then
      start_tmux=(no)
    else
      # 'integrated', 'isolated', 'system', or 'command' <cmd> [arg]...
      zstyle -a :z4d: start-tmux start_tmux || start_tmux=(isolated)
      if (( $#start_tmux == 1 )); then
        case $start_tmux[1] in
          integrated|isolated) install_tmux=1;;
          system)     start_tmux=(command tmux -u);;
        esac
      fi
    fi

    if [[ -n $_Z4D_TMUX_TTY && $_Z4D_TMUX_TTY != $TTY ]]; then
      [[ $TMUX == $_Z4D_TMUX ]] && unset TMUX TMUX_PANE
      unset _Z4D_TMUX _Z4D_TMUX_PANE _Z4D_TMUX_CMD _Z4D_TMUX_TTY
    elif [[ -n $_Z4D_TMUX_CMD ]]; then
      install_tmux=1
    fi

    if ! [[ _z4d_zle -eq 1 && -o zle && -t 0 && -t 1 && -t 2 ]]; then
      unset _Z4D_TMUX _Z4D_TMUX_PANE _Z4D_TMUX_CMD _Z4D_TMUX_TTY
    else
      local tmux=$Z4D/tmux/bin/tmux
      local -a match mbegin mend
      if [[ $TMUX == (#b)(/*),(|<->),(|<->) && -w $match[1] ]]; then
        if [[ $TMUX == */z4d-tmux-* ]]; then
          export _Z4D_TMUX=$TMUX
          export _Z4D_TMUX_PANE=$TMUX_PANE
          export _Z4D_TMUX_CMD=$tmux
          export _Z4D_TMUX_TTY=$TTY
          unset TMUX TMUX_PANE
        elif [[ -x /proc/$match[2]/exe ]]; then
          export _Z4D_TMUX=$TMUX
          export _Z4D_TMUX_PANE=$TMUX_PANE
          export _Z4D_TMUX_CMD=/proc/$match[2]/exe
          export _Z4D_TMUX_TTY=$TTY
        elif (( $+commands[tmux] )); then
          export _Z4D_TMUX=$TMUX
          export _Z4D_TMUX_PANE=$TMUX_PANE
          export _Z4D_TMUX_CMD=$commands[tmux]
          export _Z4D_TMUX_TTY=$TTY
        else
          unset _Z4D_TMUX _Z4D_TMUX_PANE _Z4D_TMUX_CMD _Z4D_TMUX_TTY
        fi
        if [[ -n $_Z4D_TMUX && -t 1 ]] &&
           zstyle -T :z4d: prompt-at-bottom &&
           ! zselect -t0 -r 0; then
          local cursor_y cursor_x
          -z4d-get-cursor-pos 1 || cursor_y=0
          local -i n='LINES - cursor_y'
          print -rn -- ${(pl:$n::\n:)}
        fi
      elif (( install_tmux )) &&
           [[ -z $TMUX && ! -w ${_Z4D_TMUX%,(|<->),(|<->)} && -z $Z4D_SSH ]]; then
        unset _Z4D_TMUX _Z4D_TMUX_PANE _Z4D_TMUX_CMD _Z4D_TMUX_TTY TMUX TMUX_PANE
        if [[ -x $tmux && -d $Z4D/terminfo ]]; then
          # We prefer /tmp over $TMPDIR because the latter breaks rendering
          # of wide chars on iTerm2.
          local sock
          if [[ -n $TMUX_TMPDIR && -d $TMUX_TMPDIR && -w $TMUX_TMPDIR ]]; then
            sock=$TMUX_TMPDIR
          elif [[ -d /tmp && -w /tmp ]]; then
            sock=/tmp
          elif [[ -n $TMPDIR && -d $TMPDIR && -w $TMPDIR ]]; then
            sock=$TMPDIR
          fi
          if [[ -n $sock ]]; then
            local tmux_suf
            local -a cmds=()
            sock=${sock%/}/z4d-tmux-$UID
            if (( terminfo[colors] >= 256 )); then
              cmds+=(set -g default-terminal tmux-256color ';')
              if [[ $COLORTERM == (24bit|truecolor) ]]; then
                cmds+=(set -ga terminal-features ',*:RGB:usstyle:overline' ';')
                sock_suf+='-tc'
              fi
            else
              cmds+=(set -g default-terminal screen ';')
            fi
            if zstyle -t :z4d: term-vresize top; then
              cmds+=(set -g history-limit 1024 ';')
              sock_suf+='-h'
            fi
            if [[ $start_tmux[1] == isolated ]]; then
              sock+=-$sysparams[pid]
            else
              sock+=-$TERM$sock_suf
              if [[ -e $Z4D/tmux/stamp ]]; then
                # Append a unique per-installation number to the socket path to work
                # around a bug in tmux. See https://github.com/romkatv/zsh4humans/issues/71.
                local stamp
                IFS= read -r stamp <$Z4D/tmux/stamp || return
                sock+=-${stamp%%.*}
              fi
            fi
            if zstyle -t :z4d: propagate-cwd && [[ -n $TTY && $TTY != *(.| )* ]]; then
              if [[ $PWD == /* && $PWD -ef . ]]; then
                local orig_dir=$PWD
              else
                local orig_dir=${${:-.}:a}
              fi
              if [[ -n "$TMPDIR" && ( ( -d "$TMPDIR" && -w "$TMPDIR" ) || ! ( -d /tmp && -w /tmp ) ) ]]; then
                local tmpdir=$TMPDIR
              else
                local tmpdir=/tmp
              fi
              local dir=$tmpdir/z4d-tmux-cwd-$UID-$$-${TTY//\//.}
              {
                zf_mkdir -p -- $dir &&
                  print -r -- "TMUX=${(q)sock} TMUX_PANE= ${(q)tmux} "'"$@"' >$dir/tmux &&
                  builtin cd -q -- $dir
              } 2>/dev/null
              if (( $? )); then
                zf_rm -rf -- "$dir" 2>/dev/null
                local exec=
              else
                export _Z4D_ORIG_CWD=$orig_dir
                local exec=
              fi
            else
              local exec=exec
            fi
            SHELL=$_z4d_exe _Z4D_LINES=$LINES _Z4D_COLUMNS=$COLUMNS \
              builtin $exec - $tmux -u -S $sock -f $Z4D/zsh4doug/.tmux.conf -- \
              "${cmds[@]}" new >/dev/null || return
            [[ -z $exec ]] || return
            builtin cd /
            zf_rm -rf -- $dir 2>/dev/null
            builtin exit 0
          fi
        else
          need_restart=1
        fi
      elif [[ -z $TMUX && $start_tmux[1] == command ]] && (( $+commands[$start_tmux[2]] )); then
        if [[ -d $Z4D/terminfo ]]; then
          SHELL=$_z4d_exe exec - ${start_tmux:1} || return
        else
          need_restart=1
        fi
      fi
    fi

    if [[ -x /usr/lib/systemd/systemd || -x /lib/systemd/systemd ]]; then
      _z4d_install_queue+=(systemd)
    fi
    local brew
    if [[ -n $HOMEBREW_REPOSITORY(#qNU) &&
          ! -e $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-command-not-found/cmd/which-formula.rb &&
          -v commands[brew] ]]; then
      brew=homebrew-command-not-found
    fi
    _z4d_install_queue+=(
      zsh-history-substring-search zsh-autosuggestions zsh-completions
      zsh-syntax-highlighting terminfo fzf $brew powerlevel10k)
    (( install_tmux )) && _z4d_install_queue+=(tmux)
    if ! -z4d-install-many; then
      [[ -e $Z4D/.updating ]] || -z4d-error-command init
      return 1
    fi
    if (( _z4d_installed_something )); then
      if [[ $TERMINFO != ~/.terminfo && -e ~/.terminfo/$TERM[1]/$TERM ]]; then
        export TERMINFO=~/.terminfo
      fi
      if (( need_restart )); then
        print -ru2 ${(%):-"%F{3}z4d%f: restarting %F{2}zsh%f"}
        exec -- $_z4d_exe -i || return
      else
        print -ru2 ${(%):-"%F{3}z4d%f: initializing %F{2}zsh%f"}
        export P9K_TTY=old
      fi
    fi

    if [[ -w $TTY ]]; then
      typeset -gi _z4d_tty_fd
      sysopen -o cloexec -rwu _z4d_tty_fd -- $TTY || return
      typeset -gri _z4d_tty_fd
    elif [[ -w /dev/tty ]]; then
      typeset -gi _z4d_tty_fd
      if sysopen -o cloexec -rwu _z4d_tty_fd -- /dev/tty 2>/dev/null; then
        typeset -gri _z4d_tty_fd
      else
        unset _z4d_tty_fd
      fi
    fi

    if [[ -v _z4d_tty_fd && (-n $Z4D_SSH && -n $_Z4D_SSH_MARKER || -n $_Z4D_TMUX) ]]; then
      typeset -gri _z4d_can_save_restore_screen=1  # this parameter is read by p10k
    else
      typeset -gri _z4d_can_save_restore_screen=0  # this parameter is read by p10k
    fi

    if (( _z4d_zle )) && zstyle -t :z4d:direnv enable && [[ -e $Z4D/cache/direnv ]]; then
      -z4d-direnv-init 0 || return '_z4d_err()'
    fi

    local rc_zwcs=($ZDOTDIR/{.zshenv,.zprofile,.zshrc,.zlogin,.zlogout}.zwc(N))
    if (( $#rc_zwcs )); then
      -z4d-check-rc-zwcs $rc_zwcs || return '_z4d_err()'
    fi

    typeset -gr _z4d_orig_shell=${SHELL-}
  } || return

  : ${ZLE_RPROMPT_INDENT:=0}

  # Enable Powerlevel10k instant prompt.
  (( ! _z4d_zle )) || zstyle -t :z4d:powerlevel10k channel none || () {
    local user=${(%):-%n}
    local XDG_CACHE_HOME=$Z4D/cache/powerlevel10k
    [[ -r $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh ]] || return 0
    builtin source $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh
  }

  local -i z4d_no_flock

  {
    () {
      eval "$_z4d_opt"
      -z4d-init && return
      [[ -e $Z4D/.updating ]] || -z4d-error-command init
      return 1
    }
  } always {
    (( z4d_no_flock )) || setopt hist_fcntl_lock
  }
}

function -z4d-cmd-install() {
  eval "$_z4d_opt"
  -z4d-check-core-params || return

  local -a flush
  zparseopts -D -F -- f=flush -flush=flush || return '_z4d_err()'

  local invalid=("${@:#([^/]##/)##[^/]##}")
  if (( $#invalid )); then
    print -Pru2 -- '%F{3}z4d%f: %Binstall%b: invalid project name(s)'
    print -Pru2 -- ''
    print -Prlu2 -- '  %F{1}'${(q)^invalid//\%/%%}'%f'
    return 1
  fi
  _z4d_install_queue+=("$@")
  (( $#flush && $#_z4d_install_queue )) || return 0
  -z4d-install-many && return
  -z4d-error-command install
  return 1
}

# Main zsh4doug function. Type `z4d help` for usage.
function z4d() {
  if (( ${+functions[-z4d-cmd-${1-}]} )); then
    -z4d-cmd-"$1" "${@:2}"
  else
    -z4d-cmd-help >&2
    return 1
  fi
}

[[ ${Z4D_SSH-} != <1->:* ]] || -z4d-ssh-maybe-update || return

unset KITTY_SHELL_INTEGRATION ITERM_INJECT_SHELL_INTEGRATION
