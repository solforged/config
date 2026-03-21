{ lib, osConfig, ... }:
let
  cfg = osConfig.platform;
  lumenEnabled = cfg.ai.lumen.enable;
  devEnabled = cfg.profiles.development.enable;
in
{
  programs.lazygit = {
    enable = true;

    settings = {
      gui.showCommandLog = false;

      customCommands =
        # AI commit drafting (lumen)
        lib.optionals lumenEnabled [
          {
            key = "<c-l>";
            description = "Draft commit message with lumen";
            command = ''git commit -m "{{.Form.Msg}}"'';
            context = "files";
            output = "terminal";
            prompts = [
              {
                type = "menuFromCommand";
                title = "AI commit messages";
                key = "Msg";
                command = "lumen draft";
                filter = "^(?P<message>.+)$";
                valueFormat = "{{ .message }}";
                labelFormat = "{{ .message }}";
              }
            ];
          }
          {
            key = "<c-k>";
            description = "Draft commit message with context";
            command = ''git commit -m "{{.Form.Msg}}"'';
            context = "files";
            output = "terminal";
            prompts = [
              {
                type = "input";
                title = "Context (intent for this commit)";
                key = "Context";
              }
              {
                type = "menuFromCommand";
                title = "AI commit messages";
                key = "Msg";
                command = ''lumen draft -c "{{.Form.Context}}"'';
                filter = "^(?P<message>.+)$";
                valueFormat = "{{ .message }}";
                labelFormat = "{{ .message }}";
              }
            ];
          }
          {
            key = "<c-e>";
            description = "Explain selected commit with lumen";
            command = "lumen explain -c {{.SelectedCommit.Hash}}";
            context = "commits";
            output = "popup";
            loadingText = "Explaining commit...";
          }
        ]
        # Dev workflow (git-absorb, gh)
        ++ lib.optionals devEnabled [
          {
            key = "<c-a>";
            description = "Absorb staged changes into prior commits";
            command = "git absorb --and-rebase";
            context = "files";
            output = "terminal";
            loadingText = "Absorbing...";
          }
          {
            key = "<c-p>";
            description = "Create pull request";
            command = "gh pr create --fill --web";
            context = "commits";
            output = "terminal";
            loadingText = "Creating PR...";
          }
          {
            key = "<c-v>";
            description = "View pull request in browser";
            command = "gh pr view --web";
            context = "commits";
            output = "terminal";
          }
        ];
    };
  };
}
