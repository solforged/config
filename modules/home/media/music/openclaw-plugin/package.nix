{
  coreutils,
  jq,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "musicctl";
  runtimeInputs = [
    coreutils
    jq
  ];
  text = ''
    set -eu

    config_path="''${MUSICCTL_CONFIG_PATH:-$HOME/.config/musicctl/config.json}"
    local_config_path="''${MUSICCTL_LOCAL_CONFIG_PATH:-$HOME/.config/musicctl/local.json}"
    state_dir="''${MUSICCTL_STATE_DIR:-$HOME/.local/state/musicctl}"

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

    require_beets() {
      beets_enabled="$(json_query '.beets.enable')"
      [ "$beets_enabled" = "true" ] || fail "beets support is disabled in $config_path"

      beets_command="$(json_query '.beets.command')"
      beets_config_path="$(json_query '.beets.configPath')"

      command_exists "$beets_command" || fail "beets command not found on PATH: $beets_command"
      [ -f "$beets_config_path" ] || fail "missing beets config: $beets_config_path"
    }

    doctor() {
      beets_command="$(json_query '.beets.command')"
      beets_config_path="$(json_query '.beets.configPath')"
      beets_enabled="$(json_query '.beets.enable')"
      roon_command="$(json_query '.roon.command')"
      roon_config_dir="$(json_query '.roon.configDir')"
      roon_enabled="$(json_query '.roon.enable')"

      print_field "config_path" "$config_path"
      print_field "local_config_path" "$local_config_path"
      print_field "local_config_present" "$(bool_value "$( [ -f "$local_config_path" ] && printf 'true' || printf 'false' )")"
      print_field "state_dir" "$state_dir"
      print_field "beets_enabled" "$beets_enabled"
      print_field "beets_command" "$beets_command"
      print_field "beets_command_found" "$(bool_value "$( command_exists "$beets_command" && printf 'true' || printf 'false' )")"
      print_field "beets_config_path" "$beets_config_path"
      print_field "beets_config_present" "$(bool_value "$( [ -f "$beets_config_path" ] && printf 'true' || printf 'false' )")"
      print_field "roon_enabled" "$roon_enabled"
      print_field "roon_command" "$roon_command"
      print_field "roon_command_found" "$(bool_value "$( command_exists "$roon_command" && printf 'true' || printf 'false' )")"
      print_field "roon_config_dir" "$roon_config_dir"
      print_field "roon_config_present" "$(bool_value "$( [ -d "$roon_config_dir" ] && printf 'true' || printf 'false' )")"

      if [ "$beets_enabled" = "true" ] && [ ! -f "$beets_config_path" ]; then
        fail "beets is enabled but the config file is missing: $beets_config_path"
      fi
    }

    library_stats() {
      require_beets
      exec "$beets_command" -c "$beets_config_path" stats
    }

    library_search() {
      require_beets
      [ "$#" -gt 0 ] || fail "library search requires a query"
      exec "$beets_command" -c "$beets_config_path" ls "$*"
    }

    library_recent() {
      require_beets
      "$beets_command" -c "$beets_config_path" ls -s added -f "\$added\t\$albumartist\t\$album\t\$title" | tail -n 20
    }

    library_duplicates() {
      require_beets
      duplicates="$("$beets_command" -c "$beets_config_path" ls -f "\$albumartist\t\$album\t\$title" | sort | uniq -d)"
      if [ -n "$duplicates" ]; then
        printf '%s\n' "$duplicates"
      else
        printf 'no exact duplicates found\n'
      fi
    }

    library_inspect() {
      require_beets
      [ "$#" -gt 0 ] || fail "library inspect requires an album or track query"
      query="$*"
      track_matches="$("$beets_command" -c "$beets_config_path" ls -f "\$albumartist\t\$album\t\$title\t\$format\t\$bitrate\t\$path" "$query" || true)"
      album_matches="$("$beets_command" -c "$beets_config_path" ls -a -f "\$albumartist\t\$album\t\$year\t\$genre" "$query" || true)"

      [ -n "$track_matches$album_matches" ] || fail "no matches found for query: $query"

      if [ -n "$album_matches" ]; then
        printf 'albums:\n%s\n' "$album_matches"
      fi

      if [ -n "$track_matches" ]; then
        printf 'tracks:\n%s\n' "$track_matches"
      fi
    }

    roon_doctor() {
      roon_enabled="$(json_query '.roon.enable')"
      roon_command="$(json_query '.roon.command')"
      roon_config_dir="$(json_query '.roon.configDir')"

      print_field "roon_enabled" "$roon_enabled"
      print_field "roon_command" "$roon_command"
      print_field "roon_command_found" "$(bool_value "$( command_exists "$roon_command" && printf 'true' || printf 'false' )")"
      print_field "roon_config_dir" "$roon_config_dir"
      print_field "roon_config_present" "$(bool_value "$( [ -d "$roon_config_dir" ] && printf 'true' || printf 'false' )")"

      if [ "$roon_enabled" != "true" ]; then
        printf 'status: disabled\n'
        exit 0
      fi

      if ! command_exists "$roon_command"; then
        fail "roon command not found on PATH: $roon_command"
      fi

      printf 'status: bootstrap-only\n'
      printf 'next_step: launch %s manually to complete or verify local Roon access\n' "$roon_command"
    }

    usage() {
      cat <<'EOF'
    usage:
      musicctl doctor
      musicctl library stats
      musicctl library search <query>
      musicctl library recent
      musicctl library duplicates
      musicctl library inspect <album-or-track>
      musicctl roon doctor
    EOF
    }

    command=''${1:-}
    shift || true

    case "$command" in
      doctor)
        [ "$#" -eq 0 ] || fail "doctor does not accept extra arguments"
        doctor
        ;;
      library)
        subcommand=''${1:-}
        shift || true
        case "$subcommand" in
          stats)
            [ "$#" -eq 0 ] || fail "library stats does not accept extra arguments"
            library_stats
            ;;
          search)
            library_search "$@"
            ;;
          recent)
            [ "$#" -eq 0 ] || fail "library recent does not accept extra arguments"
            library_recent
            ;;
          duplicates)
            [ "$#" -eq 0 ] || fail "library duplicates does not accept extra arguments"
            library_duplicates
            ;;
          inspect)
            library_inspect "$@"
            ;;
          *)
            usage
            exit 1
            ;;
        esac
        ;;
      roon)
        subcommand=''${1:-}
        shift || true
        case "$subcommand" in
          doctor)
            [ "$#" -eq 0 ] || fail "roon doctor does not accept extra arguments"
            roon_doctor
            ;;
          *)
            usage
            exit 1
            ;;
        esac
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  '';
  meta = {
    description = "Read-only music library helper for sigil and OpenClaw";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "musicctl";
  };
}
