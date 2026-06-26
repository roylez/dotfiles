#!/usr/bin/env bash
# Claude Code status line

set -f

usage_dir="${CLAUDE_USAGE_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/usage}"

# budget subcommand: bash statusline-command.sh budget <new_budget>
# Updates the budget= line in .config.
if [ "${1:-}" = "budget" ] && [ -n "${2:-}" ]; then
    [ ! -f "$usage_dir/.config" ] && echo "no config at $usage_dir/.config" && exit 1
    sed -i '' "s/^budget=.*/budget=$2/" "$usage_dir/.config"
    cat "$usage_dir/.config"
    exit 0
fi

# usage subcommand: bash statusline-command.sh usage <initial_usage>
# Directly overwrites initial_usage= in .config (no offset files written).
if [ "${1:-}" = "usage" ] && [ -n "${2:-}" ]; then
    [ ! -f "$usage_dir/.config" ] && echo "no config at $usage_dir/.config" && exit 1
    sed -i '' "s/^initial_usage=.*/initial_usage=$2/" "$usage_dir/.config"
    cat "$usage_dir/.config"
    exit 0
fi

# sync subcommand: bash statusline-command.sh sync <real_usage>
# Writes a negative offset for each session so continuing sessions only
# count the delta. Dead sessions cancel out (cost + -cost = 0).
# start_ts=0 disables timestamp filtering — offsets handle the math.
if [ "${1:-}" = "sync" ] && [ -n "${2:-}" ]; then
    [ ! -f "$usage_dir/.config" ] && echo "no config at $usage_dir/.config" && exit 1
    set +f
    for f in "$usage_dir"/*; do
        [ ! -f "$f" ] && continue
        base=$(basename "$f")
        case "$base" in .* | *_offset) continue ;; esac
        cost=$(awk -F'\t' '{print $2}' "$f")
        [ -n "$cost" ] && printf '%s\t-%s\toffset\t0\t0\t0\n' "$(date +%s)" "$cost" > "${f}_offset"
    done
    set -f
    sed -i '' "s/^initial_usage=.*/initial_usage=$2/; s/^start_ts=.*/start_ts=0/" "$usage_dir/.config"
    cat "$usage_dir/.config"
    exit 0
fi

# pr-refresh subcommand: bash statusline-command.sh pr-refresh <repo_root> <branch>
# Background-fetches the open PR number for <branch> into <repo_root>/local/.pr-cache.
# Runs detached from the render; failures are silent (the cache keeps its last
# value until a refresh succeeds). An empty result drops the branch's entry, so
# a merged/closed PR stops showing on the next refresh.
if [ "${1:-}" = "pr-refresh" ] && [ -n "${2:-}" ] && [ -n "${3:-}" ]; then
    root="$2"; br="$3"
    [ -d "$root/local" ] || exit 0
    # Mirror the .zshrc gh wrapper: Minca repos use the gh-minca account config.
    case "$root/" in "$HOME/Code/minca/"*) export GH_CONFIG_DIR="$HOME/.config/gh-minca" ;; esac
    git -C "$root" --no-optional-locks fetch --quiet 2>/dev/null
    num=$(cd "$root" && gh pr list --head "$br" --state open --json number \
          --jq '.[0].number // empty' 2>/dev/null)
    cache="$root/local/.pr-cache"
    tmp=$(mktemp "${cache}.XXXXXX") || exit 0
    [ -f "$cache" ] && awk -F'\t' -v b="$br" '$1 != b' "$cache" > "$tmp"
    [ -n "$num" ] && printf '%s\t%s\n' "$br" "$num" >> "$tmp"
    mv "$tmp" "$cache"
    exit 0
fi

input=$(cat)
[ -z "$input" ] && printf "Claude" && exit 0

# ===== Colors =====
blue='\033[38;2;97;175;239m'
amber='\033[38;2;229;192;123m'
cyan='\033[38;2;86;182;194m'
green='\033[38;2;80;200;120m'
orange='\033[38;2;255;176;85m'
yellow='\033[38;2;230;200;0m'
red='\033[38;2;235;87;87m'
magenta='\033[38;2;198;120;221m'
dim='\033[2m'
reset='\033[0m'

sep=" ${dim}│${reset} "

# ===== Helpers =====

fmt_time() {
    local m="$1"
    [ -z "$m" ] && return
    [ "$m" -gt 99 ] && echo "$((m / 60))h" || echo "${m}m"
}

# epoch seconds → local clock time (HH:MM). BSD date -r, GNU date -d fallback.
fmt_clock() {
    local ts="$1"
    [ -z "$ts" ] && return
    date -r "$ts" +%H:%M 2>/dev/null || date -d "@$ts" +%H:%M 2>/dev/null
}

# projected% = used% × duration / elapsed
# ↑ will exhaust before reset | → on pace | ↓ under-consuming
pace_arrow() {
    local used_pct="$1" resets_at="$2" duration="$3" now="$4"
    [ -z "$used_pct" ] || [ -z "$resets_at" ] && return
    local elapsed=$(( now - (resets_at - duration) ))
    [ "$elapsed" -le $(( duration / 50 )) ] && return
    local projected pace_pct
    projected=$(echo "$used_pct * $duration / $elapsed" | bc 2>/dev/null)
    pace_pct=$(echo "$elapsed * 100 / $duration" | bc 2>/dev/null)
    [ -z "$projected" ] && return
    local time_left_m remaining_m time_color time_left_fmt arrow_str pace_str
    time_left_m=$(echo "(100 - $used_pct) * $elapsed / $used_pct / 60" | bc 2>/dev/null)
    remaining_m=$(( (resets_at - now) / 60 ))

    time_color="$green"
    if [ -n "$time_left_m" ] && [ "$remaining_m" -gt 0 ] 2>/dev/null; then
        local ratio_pct=$(( time_left_m * 100 / remaining_m ))
        if   [ "$ratio_pct" -lt 33 ]; then time_color="$red"
        elif [ "$ratio_pct" -lt 66 ]; then time_color="$orange"
        fi
    fi

    # Exhaustion clock time: when usage hits 100% at the current pace.
    time_left_fmt=""
    [ -n "$time_left_m" ] && \
        time_left_fmt=" ${time_color}$(fmt_clock $(( now + time_left_m * 60 )))${reset}"

    if   [ "$projected" -gt 115 ]; then arrow_str="${red}↑${reset}"
    elif [ "$projected" -gt 85  ]; then arrow_str="${yellow}→${reset}"
    else                                 arrow_str="${green}↓${reset}"; time_left_fmt=""
    fi

    pace_str=""
    [ -n "$pace_pct" ] && pace_str=":${dim}${pace_pct}%${reset}"

    printf '%s' "${pace_str}${arrow_str}${time_left_fmt}"
}

add()  { [ -z "$out" ]   && out+="$1"   || out+="${sep}$1"; }
addu() { [ -z "$usage" ] && usage+="$1" || usage+="${sep}$1"; }

# ===== Extract data =====
model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input"   | jq -r '.workspace.current_dir // .cwd // empty')
used=$(echo "$input"  | jq -r '.context_window.used_percentage // empty')

# "Claude Opus 4.6 (1M context)" → "Opus 4.6 (1M)"
model="${model#Claude }"
model="${model/ context/}"

# Active profile = basename of CLAUDE_CONFIG_DIR (e.g. ~/.claude → "claude",
# ~/.claude-work → "claude-work"). Distinguishes per-profile aliases.
profile="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
profile="${profile##*/}"
profile="${profile#.}"
# Compact multi-word profiles: "claude-minca" → "claudem"
# (first word + first letter of the second word).
if [[ "$profile" == *-* ]]; then
    first="${profile%%-*}"
    rest="${profile#*-}"
    second="${rest%%-*}"
    profile="${first}${second:0:1}"
fi

branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

now=$(date +%s)
rl_five=$(echo "$input"      | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_seven=$(echo "$input"     | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_resets_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_resets_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

cost_usd=$(echo "$input"       | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input"    | jq -r '.cost.total_duration_ms // empty')
api_duration_ms=$(echo "$input"| jq -r '.cost.total_api_duration_ms // empty')
lines_added=$(echo "$input"    | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input"  | jq -r '.cost.total_lines_removed // empty')
session_id=$(echo "$input"     | jq -r '.session_id // empty')
transcript_path=$(echo "$input"| jq -r '.transcript_path // empty')
transcript_file="${transcript_path##*/}"
transcript_file="${transcript_file%.jsonl}"
effort_level=$(echo "$input"   | jq -r '.effort.level // empty')
agent_name=$(echo "$input"     | jq -r '.agent.name // empty')
total_input=$(echo "$input"    | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input"   | jq -r '.context_window.total_output_tokens // empty')
cache_read=$(echo "$input"     | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_create=$(echo "$input"   | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')

# ===== PR number for the current branch =====
# Read instantly from a gitignored cache under the repo's local/ dir, then
# refresh it in the background — debounced so frequent renders don't spawn gh.
# A new branch (no lock entry) refreshes at once; otherwise at most every 10 min.
# The cached value never expires on its own; it is only overwritten by a refresh.
pr_num=""
if [ -n "$branch" ] && [ -n "$cwd" ]; then
    repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_root" ] && [ -d "$repo_root/local" ]; then
        pr_cache="$repo_root/local/.pr-cache"
        pr_lock="$repo_root/local/.pr-cache.lock"
        [ -f "$pr_cache" ] && \
            pr_num=$(awk -F'\t' -v b="$branch" '$1==b {print $2; exit}' "$pr_cache")
        last=$(awk -F'\t' -v b="$branch" '$1==b {print $2; exit}' "$pr_lock" 2>/dev/null)
        if [ -z "$last" ] || [ $(( now - last )) -gt 600 ]; then
            # Stamp the attempt first (debounce even if the refresh fails), then detach.
            if tmp_lock=$(mktemp "${pr_lock}.XXXXXX" 2>/dev/null); then
                [ -f "$pr_lock" ] && awk -F'\t' -v b="$branch" '$1!=b' "$pr_lock" > "$tmp_lock"
                printf '%s\t%s\n' "$branch" "$now" >> "$tmp_lock"
                mv "$tmp_lock" "$pr_lock"
            fi
            ( bash "$0" pr-refresh "$repo_root" "$branch" >/dev/null 2>&1 & )
        fi
    fi
fi

# ===== Usage tracking =====
today=$(date +%Y-%m-%d)
daily_total=""

if [ -n "$session_id" ] && [ -n "$cost_usd" ] && [ -z "$rl_five" ] && [ -z "$rl_seven" ]; then
    mkdir -p "$usage_dir"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$now" "$cost_usd" "${model:-unknown}" \
        "${api_duration_ms:-0}" "${lines_added:-0}" "${lines_removed:-0}" \
        > "$usage_dir/$session_id"
fi

# Load config: budget, initial_usage, start_ts (epoch)
budget="" initial_usage="" start_ts=""
[ -f "$usage_dir/.config" ] && . "$usage_dir/.config" 2>/dev/null
period_total=""
if [ -n "$budget" ] && [ -n "$start_ts" ]; then
    set +f
    tracked=$(awk -v t="$start_ts" -F'\t' '($1+0) >= (t+0) {s += $2} END {printf "%.2f", s}' "$usage_dir"/* 2>/dev/null)
    set -f
    period_total=$(echo "scale=2; ${initial_usage:-0} + ${tracked:-0}" | bc 2>/dev/null)
fi

# ===== Assemble =====
out=""
usage=""

# Profile badge — color auto-derived from the name so each profile is
# visually distinct without hardcoding any specific profile.
if [ -n "$profile" ]; then
    palette=("$blue" "$amber" "$cyan" "$green" "$magenta" "$orange")
    pidx=$(( $(printf '%s' "$profile" | cksum | cut -d' ' -f1) % ${#palette[@]} ))
    add "${palette[$pidx]}${profile}${reset}"
fi

# Model — amber for Opus, cyan for Haiku, blue otherwise
if [ -n "$model" ]; then
    model_color="$blue"
    case "$model" in *Opus*)  model_color="$amber" ;; *Haiku*) model_color="$cyan" ;; esac
    add "${model_color}${model}${reset}"
fi

# Effort level
if [ -n "$effort_level" ]; then
    case "$effort_level" in
        low)    effort_color="$dim" ;;
        medium) effort_color="$cyan" ;;
        high)   effort_color="$orange" ;;
        xhigh)  effort_color="$red" ;;
        max)    effort_color="$red" ;;
        *)      effort_color="$dim" ;;
    esac
    add "${effort_color}${effort_level}${reset}"
fi

# Agent name
[ -n "$agent_name" ] && add "${dim}agent:${reset}${cyan}${agent_name}${reset}"

# Git branch + dirty state
if [ -n "$branch" ]; then
    git_str="${dim}⎇${reset} ${magenta}${branch}${reset}"
    porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -z "$porcelain" ]; then
        git_str+=" ${green}${dim}✓${reset}"
    else
        staged=$(  printf '%s\n' "$porcelain" | awk '/^[MADRC]/'        | wc -l | tr -d ' ')
        modified=$(printf '%s\n' "$porcelain" | awk '/^.[MD]/'          | wc -l | tr -d ' ')
        untracked=$(printf '%s\n' "$porcelain" | awk '/^\?\?/'          | wc -l | tr -d ' ')
        [ "$staged"    -gt 0 ] && git_str+=" ${green}+${staged}${reset}"
        [ "$modified"  -gt 0 ] && git_str+=" ${yellow}~${modified}${reset}"
        [ "$untracked" -gt 0 ] && git_str+=" ${dim}?${untracked}${reset}"
    fi
    unpushed=$(git -C "$cwd" --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null)
    [ -n "$unpushed" ] && [ "$unpushed" -gt 0 ] && git_str+=" ${orange}⇡${unpushed}${reset}"
    unpulled=$(git -C "$cwd" --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null)
    [ -n "$unpulled" ] && [ "$unpulled" -gt 0 ] && git_str+=" ${cyan}⇣${unpulled}${reset}"
    add "$git_str"
fi

# Pending ScheduleWakeup (shadowed by hooks/wakeup-marker.sh)
wakeup_file="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/next-wakeup"
wakeup_reason=""
if [ -f "$wakeup_file" ]; then
    wakeup_line=$(head -n1 "$wakeup_file" 2>/dev/null)
    wakeup_ts="${wakeup_line%%	*}"
    wakeup_reason="${wakeup_line#*	}"
    if [ -n "$wakeup_ts" ] && [ "$wakeup_ts" -gt "$now" ] 2>/dev/null; then
        secs_left=$(( wakeup_ts - now ))
        if [ "$secs_left" -lt 60 ]; then wake_fmt="${secs_left}s"
        elif [ "$secs_left" -lt 3600 ]; then wake_fmt="$((secs_left/60))m$((secs_left%60))s"
        else wake_fmt="$((secs_left/3600))h$(( (secs_left%3600)/60 ))m"
        fi
        add "${yellow}⏰ ${wake_fmt}${reset}"
    else
        wakeup_reason=""
        rm -f "$wakeup_file" 2>/dev/null
    fi
fi

# Context window %
if [ -n "$used" ]; then
    ctx_pct=$(printf "%.0f" "$used")
    if   [ "$ctx_pct" -ge 80 ]; then ctx_color="$red"
    elif [ "$ctx_pct" -ge 50 ]; then ctx_color="$orange"
    else ctx_color="$cyan"; fi
    add "${dim}ctx${reset} ${ctx_color}${ctx_pct}%${reset}"
fi

# Rate limits — 5h
if [ -n "$rl_five" ]; then
    f=$(printf "%.0f" "$rl_five")
    arrow5=$(pace_arrow "$rl_five" "$rl_resets_5h" 18000 "$now")

    if   [ "$f" -ge 80 ]; then pct_color="$red"
    elif [ "$f" -ge 50 ]; then pct_color="$yellow"
    else pct_color="$cyan"; fi

    t5=""
    [ -n "$rl_resets_5h" ] && [ "$rl_resets_5h" -gt "$now" ] 2>/dev/null && \
        t5=$(fmt_time $(( (rl_resets_5h - now) / 60 )))

    if [ -n "$t5" ]; then
        addu "${pct_color}${t5}:${f}%${arrow5}${reset}"
    else
        addu "${pct_color}${f}%${arrow5}${reset}"
    fi
fi

# Rate limits — 7d
if [ -n "$rl_seven" ]; then
    s=$(printf "%.0f" "$rl_seven")
    arrow7=$(pace_arrow "$rl_seven" "$rl_resets_7d" 604800 "$now")

    t7=""
    [ -n "$rl_resets_7d" ] && [ "$rl_resets_7d" -gt "$now" ] 2>/dev/null && \
        t7=$(fmt_time $(( (rl_resets_7d - now) / 60 )))

    if [ -n "$t7" ]; then
        addu "${cyan}${t7}:${s}%${arrow7}${reset}"
    else
        addu "${cyan}7d:${s}%${arrow7}${reset}"
    fi
fi

# Cache hit rate — also shown alongside rate limits
if [ -n "$rl_five" ] || [ -n "$rl_seven" ]; then
    cache_total=$(( ${cache_read:-0} + ${cache_create:-0} ))
    if [ "$cache_total" -gt 0 ] 2>/dev/null; then
        hit_pct=$(( cache_read * 100 / cache_total ))
        if   [ "$hit_pct" -ge 80 ]; then cache_color="$green"
        elif [ "$hit_pct" -ge 50 ]; then cache_color="$cyan"
        else cache_color="$orange"; fi
        addu "${dim}cache${reset} ${cache_color}${hit_pct}%${reset}"
    fi
fi

# API cost fallback — shown when no rate_limits (enterprise/API billing)
if [ -z "$rl_five" ] && [ -z "$rl_seven" ] && [ -n "$cost_usd" ]; then
    cost_fmt=$(printf "$%.2f" "$cost_usd")

    # Active burn rate (cost / api hours) — used by budget calc, not displayed
    active_rate=""
    if [ -n "$api_duration_ms" ] && [ "$api_duration_ms" -gt 0 ] 2>/dev/null; then
        active_rate=$(echo "scale=2; $cost_usd / ($api_duration_ms / 3600000)" | bc 2>/dev/null)
    fi

    # Cache hit rate — cache_read / (cache_read + cache_create)
    cache_total=$(( ${cache_read:-0} + ${cache_create:-0} ))
    if [ "$cache_total" -gt 0 ] 2>/dev/null; then
        hit_pct=$(( cache_read * 100 / cache_total ))
        if   [ "$hit_pct" -ge 80 ]; then cache_color="$green"
        elif [ "$hit_pct" -ge 50 ]; then cache_color="$cyan"
        else cache_color="$orange"; fi
        addu "${dim}cache${reset} ${cache_color}${hit_pct}%${reset}"
    fi

    # Cost per 1k tokens + net lines
    total_tokens=$(( ${total_input:-0} + ${total_output:-0} ))
    if [ "$total_tokens" -gt 0 ] 2>/dev/null; then
        cpk=$(echo "scale=2; $cost_usd * 1000 / $total_tokens" | bc 2>/dev/null)
        if [ -n "$cpk" ] && [ "$(echo "$cpk > 0" | bc 2>/dev/null)" = "1" ]; then
            net_lines=$(( ${lines_added:-0} - ${lines_removed:-0} ))
            if [ "$net_lines" -ge 0 ]; then
                net_str="${green}+${net_lines}${reset}"
            else
                net_str="${red}${net_lines}${reset}"
            fi
            addu "${dim}\$${cpk}/kt${reset} ${net_str}"
        fi
    fi

    # Budget tracking — accumulated across billing period
    if [ -n "$period_total" ] && [ -n "$budget" ] && [ -n "$active_rate" ]; then
        budget_pct=$(echo "scale=0; $period_total * 100 / $budget" | bc 2>/dev/null)
        if [ -n "$budget_pct" ]; then
            if   [ "$budget_pct" -ge 80 ]; then bgt_color="$red"
            elif [ "$budget_pct" -ge 50 ]; then bgt_color="$yellow"
            else bgt_color="$cyan"; fi

            remaining_usd=$(echo "scale=2; $budget - $period_total" | bc 2>/dev/null)
            time_left_m=""
            if [ -n "$remaining_usd" ]; then
                cmp=$(echo "$active_rate > 0" | bc 2>/dev/null)
                [ "$cmp" = "1" ] && \
                    time_left_m=$(echo "scale=0; $remaining_usd * 60 / $active_rate" | bc 2>/dev/null)
            fi

            time_left_fmt=""
            if [ -n "$time_left_m" ] && [ "$time_left_m" -ge 0 ] 2>/dev/null; then
                tlf=$(fmt_time "$time_left_m")
                time_left_fmt=" ${dim}${tlf}${reset}"
            fi

            period_fmt=$(printf "$%.2f" "$period_total")
            addu "${bgt_color}${period_fmt}/${budget}${time_left_fmt}${reset}"
        fi
    fi
fi

# Last interaction time — transcript mtime, shown next to cache on the usage
# line — followed by the next 5h rate-limit reset clock time.
last_ts=""
[ -n "$transcript_path" ] && [ -f "$transcript_path" ] && \
    last_ts=$(stat -f %m "$transcript_path" 2>/dev/null || stat -c %Y "$transcript_path" 2>/dev/null)
clock_str=""
if [ -n "$last_ts" ]; then
    _clk=$(fmt_clock "$last_ts")
    [ -n "$_clk" ] && clock_str="${dim}${_clk}${reset}"
fi

reset_str=""
if [ -n "$rl_resets_5h" ] && [ "$rl_resets_5h" -gt "$now" ] 2>/dev/null; then
    _rst=$(fmt_clock "$rl_resets_5h")
    [ -n "$_rst" ] && reset_str="${dim}↻ ${_rst}${reset}"
fi

[ -n "$clock_str" ] && [ -n "$reset_str" ] && addu "${clock_str} ${reset_str}"
[ -n "$clock_str" ] && [ -z "$reset_str" ] && addu "$clock_str"
[ -z "$clock_str" ] && [ -n "$reset_str" ] && addu "$reset_str"

# PR for the current branch — pinned to the end of the usage line
[ -n "$pr_num" ] && addu "${blue}PR#${pr_num}${reset}"

[ -n "$usage" ] && add "$usage"

if [ -n "$cwd" ]; then
    cwd_display="${cwd/#$HOME/~}"
    add "${dim}${cwd_display}${reset}"
fi
[ -n "$transcript_file" ] && add "${dim}${transcript_file}${reset}"
[ -n "$wakeup_reason" ] && add "${dim}⏰ ${wakeup_reason}${reset}"

printf "%b\n" "$out"
