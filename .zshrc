# Shell history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history

# Tab completion
autoload -Uz compinit
compinit

# Local command-line tools
export PATH="$HOME/.local/bin:$PATH"

# Spaceship prompt (installed via Homebrew)
if (( $+commands[brew] )); then
  spaceship_prompt="$(brew --prefix)/opt/spaceship/spaceship.zsh"
  [[ -f "$spaceship_prompt" ]] && source "$spaceship_prompt"
  unset spaceship_prompt
fi
