# Worktrunk user-level hooks.
#
# These run across all repositories. Project-specific hooks (formatters,
# linters, tests) belong in each repo's .config/wt.toml instead.
{ ... }:
{
  xdg.configFile."worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}"

    [post-switch]
    zellij = """
    if [ -n "$ZELLIJ" ]; then
      zellij action rename-tab {{ branch | sanitize }}
    fi
    """
  '';
}
