# Worktrunk user-level hooks.
#
# These run across all repositories. Project-specific hooks (formatters,
# linters, tests) belong in each repo's .config/wt.toml instead.
{ ... }:
let
  claude = "claude-bun";
in
{
  xdg.configFile."worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}"

    [commit.generation]
    command = "CLAUDECODE= MAX_THINKING_TOKENS=0 ${claude} -p --no-session-persistence --model=haiku --tools=\"\" --disable-slash-commands --setting-sources=\"\" --system-prompt=\"\""

    [post-switch]
    zellij = """
    if [ -n "$ZELLIJ" ]; then
      zellij action rename-tab {{ branch | sanitize }}
    fi
    """
  '';
}
