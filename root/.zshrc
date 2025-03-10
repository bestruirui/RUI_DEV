# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# go
export PATH=$PATH:/usr/local/go/bin

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source ~/.config/zsh/theme/powerlevel10k/powerlevel10k.zsh-theme

source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

zstyle ':completion:*' menu yes select search

fpath=(~/.config/zsh/completion/zsh-completion/src $fpath)
fpath=(~/.config/zsh/completion $fpath)

autoload -Uz compinit && compinit -i


[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# color
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# History configuration
HISTFILE=~/.zsh_history    # History file location
HISTSIZE=10000            # Maximum events in internal history
SAVEHIST=10000           # Maximum events in history file
setopt SHARE_HISTORY      # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS   # Don't record an entry that was just recorded again
setopt HIST_IGNORE_SPACE  # Don't record entries starting with a space
setopt HIST_VERIFY       # Show command with history expansion before running it
setopt HIST_SAVE_NO_DUPS # Don't write duplicate entries in the history file