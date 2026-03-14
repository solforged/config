#!/bin/sh
# Detect host context for Claude Code sessions
host="${RIG_HOST:-$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"
case "$host" in
  sigil)
    echo "[context] host=$host scope=personal — full repo access, all hosts in scope"
    ;;
  atlas)
    echo "[context] host=$host scope=work — CAUTION: this is a personal repo being edited from a work machine. Do not add employer-specific information (team names, internal tools, corp URLs, internal hostnames). If a change only makes sense for the work environment, suggest putting it in the work flake instead."
    ;;
  *)
    echo "[context] host=$host scope=unknown — could not determine work/personal context. Ask before making host-specific changes."
    ;;
esac
