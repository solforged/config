{
  coreutils,
  jq,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "notesctl";
  runtimeInputs = [
    coreutils
    jq
  ];
  text = ''
    set -eu

    config_path="''${NOTESCTL_CONFIG_PATH:-$HOME/.config/notesctl/config.json}"
    local_config_path="''${NOTESCTL_LOCAL_CONFIG_PATH:-$HOME/.config/notesctl/local.json}"
    state_dir="''${NOTESCTL_STATE_DIR:-$HOME/.local/state/notesctl}"

    fail() {
      printf 'error: %s\n' "$1" >&2
      exit 1
    }

    bool_value() {
      value="$1"
      if [ "$value" = "true" ]; then
        printf 'true\n'
      else
        printf 'false\n'
      fi
    }

    print_field() {
      printf '%s: %s\n' "$1" "$2"
    }

    load_config() {
      if [ ! -f "$config_path" ]; then
        fail "missing config file: $config_path"
      fi

      if [ -f "$local_config_path" ]; then
        jq -s '.[0] * .[1]' "$config_path" "$local_config_path"
      else
        jq '.' "$config_path"
      fi
    }

    json_query() {
      load_config | jq -er "$1"
    }

    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    slugify() {
      printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | tr -cs '[:alnum:]' '-' \
        | sed 's/^-//; s/-$//'
    }

    timestamp() {
      date '+%Y%m%d-%H%M%S'
    }

    require_payload() {
      payload_file="$1"

      [ -f "$payload_file" ] || fail "payload file not found: $payload_file"

      jq -e '
        type == "object"
        and (.title | type == "string" and length > 0)
        and (.summary | type == "string" and length > 0)
      ' "$payload_file" >/dev/null || fail "payload must be a JSON object with non-empty title and summary"
    }

    payload_with_defaults() {
      payload_file="$1"
      defaults_json="$2"

      jq \
        --arg now "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --argjson defaultTags "$defaults_json" \
        '
          .captured_at = (.captured_at // $now)
          | .people = (.people // [])
          | .tags = ((.tags // []) + $defaultTags | unique)
          | .decisions = (.decisions // [])
          | .followups = (.followups // [])
          | .tasks = (.tasks // [])
        ' \
        "$payload_file"
    }

    note_paths() {
      vault_path="$(json_query '.vaultPath // empty')"
      inbox_dir="$(json_query '.inboxDir')"

      [ -n "$vault_path" ] || fail "vaultPath is not configured"

      note_dir="$vault_path/$inbox_dir"
      printf '%s\n%s\n' "$vault_path" "$note_dir"
    }

    note_path_for_payload() {
      payload_file="$1"
      default_tags="$(json_query '.defaultTags')"
      payload="$(payload_with_defaults "$payload_file" "$default_tags")"
      note_title="$(printf '%s' "$payload" | jq -r '.title')"
      note_slug="$(slugify "$note_title")"
      note_stamp="$(timestamp)"

      vault_path_and_dir="$(note_paths)"
      vault_path="$(printf '%s' "$vault_path_and_dir" | sed -n '1p')"
      note_dir="$(printf '%s' "$vault_path_and_dir" | sed -n '2p')"
      note_path="$note_dir/$note_stamp-$note_slug.md"

      printf '%s\n%s\n%s\n' "$vault_path" "$note_dir" "$note_path"
    }

    sync_task_payload() {
      payload_file="$1"
      note_path="$2"

      task_enabled="$(json_query '.taskwarrior.enable')"
      if [ "$task_enabled" != "true" ]; then
        jq '.' "$payload_file"
        return 0
      fi

      task_data_dir="$(json_query '.taskwarrior.dataDir // empty')"
      task_project="$(json_query '.taskwarrior.project // empty')"
      task_tags="$(json_query '.taskwarrior.tags')"
      task_command="task"

      command_exists "$task_command" || fail "task command not found on PATH"

      tmp_payload="$(mktemp "$state_dir/task-payload.XXXXXX.json")"
      trap 'rm -f "$tmp_payload"' EXIT
      jq '.' "$payload_file" > "$tmp_payload"

      task_count="$(jq '.tasks | length' "$tmp_payload")"
      if [ "$task_count" -eq 0 ]; then
        jq '.' "$tmp_payload"
        rm -f "$tmp_payload"
        trap - EXIT
        return 0
      fi

      note_ref="$(basename "$note_path")"
      i=0
      while [ "$i" -lt "$task_count" ]; do
        task_desc="$(jq -r ".tasks[$i].description // empty" "$tmp_payload")"
        [ -n "$task_desc" ] || fail "task at index $i is missing description"

        task_uuid="$(jq -r ".tasks[$i].uuid // empty" "$tmp_payload")"
        if [ -z "$task_uuid" ]; then
          if command_exists uuidgen; then
            task_uuid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
          else
            fail "uuidgen is required when syncing tasks without explicit uuids"
          fi
        fi

        task_project_value="$(jq -r ".tasks[$i].project // empty" "$tmp_payload")"
        if [ -z "$task_project_value" ]; then
          task_project_value="$task_project"
        fi

        task_tags_value="$(jq --argjson defaults "$task_tags" ".tasks[$i].tags = (((.tasks[$i].tags // []) + \$defaults) | unique) | .tasks[$i].tags" "$tmp_payload" | jq -c ".tasks[$i].tags")"

        task_json="$(jq -n \
          --arg uuid "$task_uuid" \
          --arg description "$task_desc" \
          --arg project "$task_project_value" \
          --argjson tags "$task_tags_value" \
          '
            {
              uuid: $uuid,
              description: $description,
              status: "pending",
              tags: $tags
            }
            + (if $project == "" then {} else { project: $project } end)
          '
        )"

        if [ -n "$task_data_dir" ]; then
          TASKDATA="$task_data_dir" "$task_command" import - <<<"$task_json" >/dev/null
          TASKDATA="$task_data_dir" "$task_command" "$task_uuid" annotate "note:$note_ref" >/dev/null
        else
          "$task_command" import - <<<"$task_json" >/dev/null
          "$task_command" "$task_uuid" annotate "note:$note_ref" >/dev/null
        fi

        jq --arg uuid "$task_uuid" --argjson tags "$task_tags_value" ".tasks[$i].uuid = \$uuid | .tasks[$i].tags = \$tags" "$tmp_payload" > "$tmp_payload.next"
        mv "$tmp_payload.next" "$tmp_payload"

        i=$((i + 1))
      done

      jq '.' "$tmp_payload"
      rm -f "$tmp_payload"
      trap - EXIT
    }

    render_markdown() {
      payload_file="$1"

      default_tags="$(json_query '.defaultTags')"
      payload="$(payload_with_defaults "$payload_file" "$default_tags")"

      printf '%s\n' "$payload" | jq -r '
        def yaml_list(items):
          if (items | length) == 0 then "[]" else
            ("\n" + (items | map("  - " + (tostring)) | join("\n")))
          end;
        def section(name; items):
          "## " + name + "\n"
          + (if (items | length) == 0 then "- None\n" else (items | map("- " + .) | join("\n")) + "\n" end);
        def tasks_section(items):
          "## Tasks\n"
          + (
            if (items | length) == 0 then "- None\n"
            else
              (
                items
                | map(
                    "- [ ] " + .description
                    + (if (.uuid // "") == "" then "" else " <!-- task:" + .uuid + " -->" end)
                  )
                | join("\n")
              ) + "\n"
            end
          );

        "---",
        "title: " + .title,
        "captured_at: " + .captured_at,
        "people:" + yaml_list(.people),
        "tags:" + yaml_list(.tags),
        "conversation_id: " + (.conversation_id // ""),
        "source_url: " + (.source_url // ""),
        "style_guide: notesctl",
        "---",
        "",
        "# Summary",
        .summary,
        "",
        section("Decisions"; .decisions),
        "",
        section("Follow-Ups"; .followups),
        "",
        tasks_section(.tasks)
      '
    }

    doctor() {
      vault_path="$(json_query '.vaultPath // empty')"
      inbox_dir="$(json_query '.inboxDir')"
      style_guide_path="$(json_query '.styleGuidePath')"
      private_style_guide_path="$(json_query '.privateStyleGuidePath // empty')"
      obsidian_enabled="$(json_query '.obsidian.enable')"
      zk_enabled="$(json_query '.zk.enable')"
      task_enabled="$(json_query '.taskwarrior.enable')"
      task_data_dir="$(json_query '.taskwarrior.dataDir // empty')"

      print_field "config_path" "$config_path"
      print_field "local_config_path" "$local_config_path"
      print_field "local_config_present" "$(bool_value "$( [ -f "$local_config_path" ] && printf 'true' || printf 'false' )")"
      print_field "state_dir" "$state_dir"
      print_field "vault_path" "$vault_path"
      print_field "vault_present" "$(bool_value "$( [ -n "$vault_path" ] && [ -d "$vault_path" ] && printf 'true' || printf 'false' )")"
      print_field "inbox_dir" "$inbox_dir"
      print_field "style_guide_path" "$style_guide_path"
      print_field "style_guide_present" "$(bool_value "$( [ -f "$style_guide_path" ] && printf 'true' || printf 'false' )")"
      print_field "private_style_guide_path" "$private_style_guide_path"
      print_field "private_style_guide_present" "$(bool_value "$( [ -n "$private_style_guide_path" ] && [ -f "$private_style_guide_path" ] && printf 'true' || printf 'false' )")"
      print_field "obsidian_enabled" "$obsidian_enabled"
      print_field "zk_enabled" "$zk_enabled"
      print_field "zk_command_found" "$(bool_value "$( command_exists zk && printf 'true' || printf 'false' )")"
      print_field "taskwarrior_enabled" "$task_enabled"
      print_field "task_command_found" "$(bool_value "$( command_exists task && printf 'true' || printf 'false' )")"
      print_field "task_data_dir" "$task_data_dir"
      print_field "task_data_present" "$(bool_value "$( [ -n "$task_data_dir" ] && [ -d "$task_data_dir" ] && printf 'true' || printf 'false' )")"
    }

    capture() {
      input_file=""
      dry_run="false"
      open_note="false"
      stdout_only="false"

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --input)
            shift
            [ "$#" -gt 0 ] || fail "--input requires a file path"
            input_file="$1"
            ;;
          --dry-run)
            dry_run="true"
            ;;
          --open)
            open_note="true"
            ;;
          --stdout)
            stdout_only="true"
            ;;
          *)
            fail "unknown capture argument: $1"
            ;;
        esac
        shift
      done

      [ -n "$input_file" ] || fail "capture requires --input <payload.json>"
      require_payload "$input_file"

      mkdir -p "$state_dir"

      note_paths_value="$(note_path_for_payload "$input_file")"
      vault_path="$(printf '%s' "$note_paths_value" | sed -n '1p')"
      note_dir="$(printf '%s' "$note_paths_value" | sed -n '2p')"
      note_path="$(printf '%s' "$note_paths_value" | sed -n '3p')"

      payload_with_tasks="$(sync_task_payload "$input_file" "$note_path")"
      payload_file="$(mktemp "$state_dir/capture.XXXXXX.json")"
      trap 'rm -f "$payload_file"' EXIT
      printf '%s\n' "$payload_with_tasks" > "$payload_file"

      markdown="$(render_markdown "$payload_file")"

      if [ "$stdout_only" = "true" ] || [ "$dry_run" = "true" ]; then
        printf '%s\n' "$markdown"
      fi

      if [ "$dry_run" != "true" ] && [ "$stdout_only" != "true" ]; then
        mkdir -p "$note_dir"
        tmp_note="$(mktemp "$note_dir/.notesctl.XXXXXX.md")"
        printf '%s\n' "$markdown" > "$tmp_note"
        mv "$tmp_note" "$note_path"
        printf '%s\n' "$note_path"
      fi

      if [ "$dry_run" != "true" ] && [ "$open_note" = "true" ]; then
        open_path "$note_path"
      fi

      rm -f "$payload_file"
      trap - EXIT
    }

    open_path() {
      note_path="$1"
      obsidian_enabled="$(json_query '.obsidian.enable')"
      obsidian_open="$(json_query '.obsidian.openWithApp')"

      if [ "$obsidian_enabled" = "true" ] && [ "$obsidian_open" = "true" ]; then
        if command -v open >/dev/null 2>&1; then
          open "$note_path"
          return 0
        fi

        if command -v xdg-open >/dev/null 2>&1; then
          xdg-open "$note_path"
          return 0
        fi
      fi

      fail "no opener available for $note_path"
    }

    render_cmd() {
      [ "$#" -eq 2 ] || fail "usage: notesctl render --input <payload.json>"
      [ "$1" = "--input" ] || fail "usage: notesctl render --input <payload.json>"
      require_payload "$2"
      render_markdown "$2"
    }

    usage() {
      cat <<'EOF'
    usage:
      notesctl doctor
      notesctl render --input <payload.json>
      notesctl capture --input <payload.json> [--dry-run] [--stdout] [--open]
    EOF
    }

    command="''${1:-}"
    shift || true

    case "$command" in
      doctor)
        [ "$#" -eq 0 ] || fail "doctor does not accept extra arguments"
        doctor
        ;;
      render)
        render_cmd "$@"
        ;;
      capture)
        capture "$@"
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  '';
}
