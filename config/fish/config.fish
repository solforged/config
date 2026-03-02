if status is-interactive
  if command -q starship
    starship init fish | source
  end
end

if set -q XDG_STATE_HOME
  set secret_fish "$XDG_STATE_HOME/dotfiles/secrets/fish/local.fish"
else
  set secret_fish "$HOME/.local/state/dotfiles/secrets/fish/local.fish"
end

if test -f "$secret_fish"
  source "$secret_fish"
end

if test -f "$HOME/.config/fish/local.fish"
  source "$HOME/.config/fish/local.fish"
end
