autoload -U colors && colors
setopt prompt_subst append_history share_history hist_ignore_dups
eval "$(dircolors -b)"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

HISTFILE=~/.zsh_history # 历史记录文件
HISTSIZE=10000          # 内存中保留的历史条数
SAVEHIST=10000          # 写入文件的历史条数

# 汇总 Git 文件状态，每种状态只在右侧提示符中显示一次。
git_prompt_status() {
  local git_status
  git_status=$(git status --porcelain 2>/dev/null) || return
  local line code added modified deleted renamed unmerged untracked output=""

  while IFS= read -r line; do
    code="${line[1,2]}"
    case "$code" in
      '??') untracked=1 ;;
      '!!') continue ;;
      DD|AU|UD|UA|DU|AA|UU) unmerged=1 ;;
      *)
        [[ "$code" == *A* ]] && added=1
        [[ "$code" == *M* ]] && modified=1
        [[ "$code" == *D* ]] && deleted=1
        [[ "$code" == *R* ]] && renamed=1
        ;;
    esac
  done <<< "$git_status"

  [[ -n "$added" ]] && output+="%{$fg[cyan]%} +"
  [[ -n "$modified" ]] && output+="%{$fg[yellow]%} ~"
  [[ -n "$deleted" ]] && output+="%{$fg[red]%} -"
  [[ -n "$renamed" ]] && output+="%{$fg[blue]%} >"
  [[ -n "$unmerged" ]] && output+="%{$fg[magenta]%} !"
  [[ -n "$untracked" ]] && output+="%{$fg[white]%} ?"
  print -r -- "$output"
}

# Git 仓库显示分支和仓库内相对路径，其他目录保持原有截断规则。
prompt_location() {
  local repo_path branch branch_color remaining

  if repo_path=$(git rev-parse --show-prefix 2>/dev/null); then
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    repo_path="${repo_path%/}"
    [[ -n "$repo_path" ]] && repo_path="/${repo_path}"
    branch_color="$fg[red]"
    [[ "$branch" == main || "$branch" == master ]] && branch_color="$fg[green]"
    print -r -- "%{$fg_bold[blue]%}(%{${branch_color}%}${branch}%{$fg_bold[blue]%})%{$fg[cyan]%}${repo_path}"
    return
  fi

  if [[ "$PWD" == /workplace || "$PWD" == /workplace/* ]]; then
    remaining="${PWD#/workplace}"
    if [[ "$remaining" == /*/*/* ]]; then
      print -r -- "%{$fg[cyan]%}@/../${PWD:h:h:t}/${PWD:h:t}/${PWD:t}"
    else
      print -r -- "%{$fg[cyan]%}@${remaining}"
    fi
    return
  fi

  print -P "%{$fg[cyan]%}%(4~|.../%3~|%~)"
}

PROMPT='%(?:%{$fg_bold[green]%}>:%{$fg_bold[red]%}>) $(prompt_location)%{$reset_color%} %(!.%{$fg_bold[red]%}#.%{$fg[white]%}$)%{$reset_color%} ' # 左侧提示符
RPROMPT='$(git_prompt_status)%{$reset_color%} %{$fg[white]%}%T%{$reset_color%}' # 右侧提示符

bindkey -e
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
eval "$("$HOME/.local/bin/mise" activate zsh)"
