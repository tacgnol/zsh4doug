'[' '-n' "${TERM-}" ']' || 'export' TERM='xterm-256color'

'[' '-n' "${WT_SESSION-}" ']' && 'export' COLORTERM="${COLORTERM:-truecolor}"

if '[' '-n' "${ZSH_VERSION-}" ']'; then
  if '[' '-n' "${_z4d_source_called+x}" ']'; then
    if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshenv\033[0m\n'
    else
      >&2 'printf' '\033[33mz4d\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m\n'
    fi
    'return' '1'
  fi

  'typeset' '-gri' _z4d_source_called='1'

  'emulate' 'zsh'
  'setopt'                                                                     \
    'always_to_end'          'auto_cd'                'auto_param_slash'       \
    'auto_pushd'             'c_bases'                'auto_menu'              \
    'extended_glob'          'extended_history'       'hist_expire_dups_first' \
    'hist_find_no_dups'      'hist_ignore_dups'       'hist_ignore_space'      \
    'hist_verify'            'interactive_comments'   'multios'                \
    'no_aliases'             'no_bg_nice'             'no_bg_nice'             \
    'no_flow_control'        'no_prompt_bang'         'no_prompt_subst'        \
    'prompt_cr'              'prompt_percent'         'prompt_sp'              \
    'share_history'          'typeset_silent'         'hist_save_no_dups'      \
    'no_auto_remove_slash'   'no_list_types'          'no_beep'

  if '[' '!' '-e' "${${TMPPREFIX:-/tmp/zsh}:h}" ']'; then
    if '[' '-n' "$TMPDIR" '-a' '-d' "$TMPDIR" '-a' '-w' "$TMPDIR" ']'; then
      'export' TMPPREFIX="${TMPDIR%/}/zsh"
    elif '[' '-d' "/tmp" '-a' '-w' "/tmp" ']'; then
      'export' TMPPREFIX="/tmp/zsh"
    fi
  fi

  if '[' "$TERMINFO" '!=' ~/'.terminfo' ']' && '[' '-e' ~/".terminfo/$TERM[1]/$TERM" ']'; then
    'export' TERMINFO=~/'.terminfo'
  fi

  'set' '-A' '_z4d_script_argv' "$@"

  if '[' '-n' "${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X}" ']'; then
    'typeset' '-gri' _z4d_zle='0'
  else
    'typeset' '-gri' _z4d_zle='1'

    PS1="%B%F{2}%n@%m%f %F{4}%~%f
%F{%(?.2.1)}%#%f%b "
    RPS1="%B%F{3}z4d recovery mode%f%b"

    WORDCHARS=''
    ZLE_REMOVE_SUFFIX_CHARS=''
    HISTSIZE='1000000000'
    SAVEHIST='1000000000'

    if '[' '-n' "$HISTFILE" ']'; then
      'typeset' '-gri' _z4d_custom_histfile='1'
    else
      'typeset' '-gri' _z4d_custom_histfile='0'
      HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
    fi

    if '[' '-n' "${_z4d_ssh_feedback-}" ']'; then
      { 'print' '-r' '--' "HISTFILE=${(q)HISTFILE}" >"$_z4d_ssh_feedback"; } 2>'/dev/null'
      'unset' '_z4d_ssh_feedback'
    fi

    if '[' '-n' "${_Z4D_LINES-}" '-a' '-n' "${_Z4D_COLUMNS-}" ']'; then
      'typeset' '-gi' LINES='_Z4D_LINES'
      'typeset' '-gi' COLUMNS='_Z4D_COLUMNS'
      'unset' '_Z4D_LINES' '_Z4D_COLUMNS'
    fi

    'bindkey' '-d'
    'bindkey' '-e'

    'bindkey' '-s' '^[OM'    '^M'
    'bindkey' '-s' '^[Ok'    '+'
    'bindkey' '-s' '^[Om'    '-'
    'bindkey' '-s' '^[Oj'    '*'
    'bindkey' '-s' '^[Oo'    '/'
    'bindkey' '-s' '^[OX'    '='
    'bindkey' '-s' '^[OH'    '^[[H'
    'bindkey' '-s' '^[OF'    '^[[F'
    'bindkey' '-s' '^[OA'    '^[[A'
    'bindkey' '-s' '^[OB'    '^[[B'
    'bindkey' '-s' '^[OD'    '^[[D'
    'bindkey' '-s' '^[OC'    '^[[C'
    'bindkey' '-s' '^[[1~'   '^[[H'
    'bindkey' '-s' '^[[4~'   '^[[F'
    'bindkey' '-s' '^[Od'    '^[[1;5D'
    'bindkey' '-s' '^[Oc'    '^[[1;5C'
    'bindkey' '-s' '^[^[[D'  '^[[1;3D'
    'bindkey' '-s' '^[^[[C'  '^[[1;3C'
    'bindkey' '-s' '^[[7~'   '^[[H'
    'bindkey' '-s' '^[[8~'   '^[[F'
    'bindkey' '-s' '^[[3\^'  '^[[3;5~'
    'bindkey' '-s' '^[^[[3~' '^[[3;3~'
    'bindkey' '-s' '^[[1;9D' '^[[1;3D'
    'bindkey' '-s' '^[[1;9C' '^[[1;3C'

    'bindkey' '^[[H'    'beginning-of-line'
    'bindkey' '^[[F'    'end-of-line'
    'bindkey' '^[[3~'   'delete-char'
    'bindkey' '^[[3;5~' 'kill-word'
    'bindkey' '^[[3;3~' 'kill-word'
    'bindkey' '^[k'     'backward-kill-line'
    'bindkey' '^[K'     'backward-kill-line'
    'bindkey' '^[j'     'kill-buffer'
    'bindkey' '^[J'     'kill-buffer'
    'bindkey' '^[/'     'redo'
    'bindkey' '^[[1;3D' 'backward-word'
    'bindkey' '^[[1;5D' 'backward-word'
    'bindkey' '^[[1;3C' 'forward-word'
    'bindkey' '^[[1;5C' 'forward-word'

    if '[' '-n' "${_Z4D_ORIG_CWD-}" ']'; then
      'builtin' 'cd' '-q' '--' "${(g:oce:)_Z4D_ORIG_CWD}" 2>'/dev/null' || 'builtin' 'cd' '-q'
      'builtin' 'unset' '_Z4D_ORIG_CWD'
      'builtin' 'eval' 'dirstack=()'
    else
      "builtin" "eval" '
        if [[ "${(%):-%1/}" == "z4d-tmux-cwd-"<->-<->-* ]]; then
          [[ -r "./tmux"(#qNU) ]] &&
            _z4d_x="$("builtin" "source" "--" "./tmux" "list-clients" "-F" "#{client_tty} #{pane_id}" 2>"/dev/null")" &&
            _z4d_x="${${(@M)${(f)_z4d_x}:#${${${(%):-%1/}#z4d-tmux-cwd-<->-<->-}//.//} %<->}##* }" &&
            [[ "$_z4d_x" == "%"<-> ]] &&
            _z4d_x="$("builtin" "source" "--" "./tmux" "display-message" "-t" "$_z4d_x" "-p" "#{pane_current_path}" 2>"/dev/null")" &&
            [[ -n "$_z4d_x" ]] &&
            "builtin" "cd" "-q" "--" "$_z4d_x" 2>"/dev/null" || "builtin" "cd" "-q"
          "builtin" "unset" "_z4d_x"
          dirstack=()
        fi'
    fi
  fi
fi

if '[' '-n' "${Z4D-}" ']' &&
   '[' "${Z4D_URL-}" '=' 'https://raw.githubusercontent.com/tacgnol/zsh4doug/v1' ']' &&
   '[' '-z' "${Z4D##/*}" '-a' '-r' "$Z4D"/zsh4doug/main.zsh ']'; then
  if '.' "$Z4D"/zsh4doug/main.zsh; then
    'setopt' 'aliases'
    'return'
  fi
  'unset' '_z4d_bootstrap'
else
  _z4d_bootstrap='1'
fi

if '[' '-n' "${_z4d_bootstrap-}" ']'; then
  'unset' '_z4d_bootstrap'
  (
    if '[' '-z' "${Z4D-}" ]; then
      >&2 'printf' '\033[33mz4d\033[0m: missing required parameter: \033[31mZ4D\033[0m\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It must be set in \033[4m~/.zshenv\033[0m:\n'
      else
        >&2 'printf' 'It must be set in \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4D:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4doug/v1}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    if '[' '-n' "${Z4D##/*}" ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: invalid \033[1mZ4D\033[0m parameter: \033[31m%s\033[0m\n' "$Z4D"
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It comes from \033[4m~/.zshenv\033[0m. Correct value example:\n'
      else
        >&2 'printf' 'It comes from \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m. Correct value example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4D:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4doug/v1}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    if '[' '!' '-r' "$Z4D"/z4d.zsh ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: confusing \033[4mz4d.zsh\033[0m location\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'Please fix \033[4m~/.zshenv\033[0m. Correct initialization example:\n'
      else
        >&2 'printf' 'Please fix \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m. Correct initialization example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4D:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4doug/v1}"\033[0m\n'
      >&2 'printf' '  \033[32m.\033[0m \033[4;33m"$Z4D"\033[0;4m/z4d.zsh\033[0m || \033[32mreturn\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) and dot (\033[32m.\033[0m) are necessary.\n'
      'exit' '1'
    fi

    if '[' '-z' "${Z4D_URL-}" ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: missing required parameter: \033[31mZ4D_URL\033[0m\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It must be set at the top of \033[4m~/.zshenv\033[0m:\n'
      else
        >&2 'printf' 'It must be set at the top of \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  Z4D_URL=\033[33m"https://raw.githubusercontent.com/tacgnol/zsh4doug/v1"\033[0m\n'
      'exit' '1'
    fi

    v="${Z4D_URL#https://raw.githubusercontent.com/tacgnol/zsh4doug/v}"

    if '[' '-z' "$v" ']' || '[' "$v" '=' "$Z4D_URL" ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: invalid \033[1mZ4D_URL\033[0m: \033[31m%s\033[0m\n' "$Z4D_URL"
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It comes from \033[4m~/.zshenv\033[0m. Correct value example:\n'
      else
        >&2 'printf' 'It comes from \033[4;33m"$ZDOTDIR"\033[0;4m/.zshenv\033[0m. Correct value example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  Z4D_URL=\033[33m"https://raw.githubusercontent.com/tacgnol/zsh4doug/v1"\033[0m\n'
      'exit' '1'
    fi

    if '[' "v$v" '!=' 'v1' ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: unexpected major version in \033[1mZ4D_URL\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Expected:\n'
      >&2 'printf' '\n'
      >&2 'printf' '  Z4D_URL=\033[33m"%s"\033[0m\n' "https://raw.githubusercontent.com/tacgnol/zsh4doug/v1"
      >&2 'printf' '\n'
      >&2 'printf' 'Found:\n'
      >&2 'printf' '\n'
      >&2 'printf' '  Z4D_URL=\033[33m"%s"\033[0m\n' "$Z4D_URL"
      >&2 'printf' '\n'
      >&2 'printf' 'Delete \033[4m%s\033[0m to switch to \033[1mv%s\033[0m.\n' "$Z4D" "$v"
      'exit' '1'
    fi

    if '[' '-e' "$Z4D"/.updating ']'; then
      >&2 'printf' '\033[33mz4d\033[0m: updating \033[1m%s\033[0m\n' "zsh4doug"
    else
      >&2 'printf' '\033[33mz4d\033[0m: installing \033[1m%s\033[0m\n' "zsh4doug"
    fi

    if '[' '-n' "${HOME-}" ']'                       &&
       '[' "$Z4D" = "$HOME"/.cache/zsh4doug/v1 ']' &&
       command -v 'id' >'/dev/null' 2>&1; then
      euid="$('command' 'id' '-u')" || 'exit'
      if '[' "$euid" '=' '0' ']'; then
        home_ls="$('command' 'ls' '-ld' '--' "$HOME")" || 'exit'
        home_owner="$('printf' '%s\n' "$home_ls" | 'command' 'awk' 'NR==1 {print $3}')" || 'exit'
        if '[' "$home_owner" '!=' 'root' ']'; then
          >&2 'printf' '\033[33mz4d\033[0m: refusing to \033[1minstall\033[0m as \033[31mroot\033[0m\n'
          'command' 'rm' '-rf' '--' "$HOME"/.cache/zsh4doug/v1 2>'/dev/null' &&
            'command' 'rmdir' '--' "$HOME"/.cache/zsh4doug "$HOME"/.cache 2>'/dev/null'
          'exit' '1'
        fi
      fi
    fi

    dir="$Z4D"/zsh4doug

    if command -v 'mktemp' >'/dev/null' 2>&1; then
      tmpdir="$('command' 'mktemp' '-d' "$dir".XXXXXXXXXX)"
    else
      tmpdir="$dir".tmp."$$"
      'command' 'rm' '-rf' '--' "$tmpdir" || 'exit'
      'command' 'mkdir' '--' "$tmpdir"    || 'exit'
    fi

    (
      if '[' '-n' "${Z4D_BOOTSTRAP_COMMAND-}" ']'; then
        Z4D_PACKAGE_NAME='zsh4doug'
        Z4D_PACKAGE_DIR="$tmpdir"/zsh4doug-"$v"
        'eval' "$Z4D_BOOTSTRAP_COMMAND" || 'exit'
      fi

      if '[' '-z' "${Z4D_BOOTSTRAP_COMMAND-}" ']'; then
        url="https://github.com/tacgnol/zsh4doug/archive/v$v.tar.gz"

        if command -v 'curl' >'/dev/null' 2>&1; then
          err="$('command' 'curl' '-fsSL' '--' "$url" 2>&1 >"$tmpdir"/snapshot.tar.gz)"
        elif command -v 'wget' >'/dev/null' 2>&1; then
          err="$('command' 'wget' '-O-'   '--' "$url" 2>&1 >"$tmpdir"/snapshot.tar.gz)"
        else
          >&2 'printf' '\033[33mz4d\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
          'exit' '1'
        fi

        if '[' "$?" '!=' '0' ']'; then
          >&2 'printf' "%s\n" "$err"
          >&2 'printf' '\033[33mz4d\033[0m: failed to download \033[31m%s\033[0m\n' "$url"
          'exit' '1'
        fi

        'command' 'tar' '-C' "$tmpdir" '-xzf' "$tmpdir"/snapshot.tar.gz || 'exit'
      fi

      if '[' '-e' "$Z4D"/.updating ']'; then
        if '[' '-z' "${Z4D_UPDATING-}" ']'; then
          >&2 'printf' '\033[33mz4d\033[0m: \033[1mZ4D_UPDATING\033[0m does not propagate through \033[32mzsh\033[0m\n'
          >&2 'printf' '\n'
          >&2 'printf' 'Change \033[32mzsh\033[0m startup files to keep \033[1mZ4D_UPDATING\033[0m intact.\n'
          'exit' '1'
        fi
        "sh" "$tmpdir"/zsh4doug-"$v"/sc/setup '-n' "$Z4D" '-o' "$Z4D_UPDATING" || 'exit'
      else
        "sh" "$tmpdir"/zsh4doug-"$v"/sc/setup '-n' "$Z4D"                      || 'exit'
      fi
      'command' 'rm' '-rf' '--' "$dir"                          || 'exit'
      'command' 'mv' '-f' '--' "$tmpdir"/zsh4doug-"$v" "$dir" || 'exit'
    )

    ret="$?"
    'command' 'rm' '-rf' '--' "$tmpdir" || 'exit'
    'exit' "$ret"
  ) && '.' "$Z4D"/zsh4doug/main.zsh && 'setopt' 'aliases' && 'return'
fi

'[' '-n' "${ZSH_VERSION-}" ']' && 'setopt' 'aliases'

>&2 'printf' '\n'
>&2 'printf' '\033[33mz4d\033[0m: \033[31mcommand failed\033[0m: \033[32m.\033[0m \033[4;33m"$Z4D"\033[0m\033[4m/z4d.zsh\033[0m\n'

'[' '-e' "$Z4D"/.updating ']' && 'return' '1'

>&2 'printf' '\033[33mz4d\033[0m: enabling \033[1mrecovery mode\033[0m\n'
>&2 'printf' '\n'
>&2 'printf' 'See error messages above to identify the culprit.\n'
>&2 'printf' '\n'
>&2 'printf' 'Edit Zsh configuration:\n'
>&2 'printf' '\n'
if [ "${ZDOTDIR:-$HOME}" '=' "$HOME" ]; then
  >&2 'printf' '  \033[32m%s\033[0m \033[4m~/.zshrc\033[0m\n' "${VISUAL:-${EDITOR:-vi}}"
else
  >&2 'printf' '  \033[32m%s\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n' "${VISUAL:-${EDITOR:-vi}}"
fi
if command -v 'zsh' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Retry Zsh initialization:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[4;32mexec\033[0m \033[32mzsh\033[0m\n'
fi
if '[' '-n' "${ZSH_VERSION-}" ']' && command -v 'z4d' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'If errors persist and you are desperate:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32mz4d\033[0m \033[1mreset\033[0m\n'
fi
if '[' '-n' "$Z4D" '-a' '-z' "${Z4D##/*}" '-a' '-r' "$Z4D"/z4d.zsh ']'; then
  >&2 'printf' '\n'
  >&2 'printf' 'If nothing helps and you are about to give up:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[35m# nuke the entire site from orbit\033[0m\n'
  >&2 'printf' '  \033[4;32msudo\033[0m \033[32mrm\033[0m -rf -- \033[4;33m"%s"\033[0m\n' "$Z4D"
fi
if command -v 'curl' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Give up and start over:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32msh\033[0m -c \033[33m"\033[0m$(\033[32mcurl\033[0m -fsSL \033[4mhttps://raw.githubusercontent.com/tacgnol/zsh4doug/v1/install\033[0m)\033[33m"\033[0m\n'
elif command -v 'wget' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Give up and start over:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32msh\033[0m -c \033[33m"\033[0m$(\033[32mwget\033[0m -O- \033[4mhttps://raw.githubusercontent.com/tacgnol/zsh4doug/v1/install\033[0m)\033[33m"\033[0m\n'
fi

>&2 'printf' '\n'

'return' '1'
