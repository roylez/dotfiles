# check if bundle command exists
! which "bundle" > /dev/null && return

if [ ! -n "$BUNDLE_EXEC_RUBY_COMMAND" ]; then
export BUNDLE_EXEC_RUBY_COMMAND=ruby
fi

function zbe-is-bundled() {
    local d="$(pwd)"
    while [[ "$(dirname $d)" != "/" ]]; do
if [ -f "$d/Gemfile" ]; then
echo $d
            return
fi
d="$(dirname $d)"
    done
}

function zbe-get-bundle-dir() {
    if [[ "$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY" != '' ]]; then
        [ ! -f './Gemfile' ] && return
echo "$(pwd)"
    else
echo "$(zbe-is-bundled)"
    fi
}

function zbe-is-exceptional(){
    [ ! -n "$BUNDLE_EXEC_COMMANDS" ] && return 1
    local acceptables
    acceptables=( $(echo "$BUNDLE_EXEC_COMMANDS") )
    for cmd in "${acceptables[@]}"; do
        [[ "$cmd" == "$1" ]] && return 1
    done
return 0
}

function zbe-bundler-driver(){
    # get path through Ruby using bundler
    cat <<-RUBY
begin
require 'bundler/setup'
cmd = "$command"
if File.file?(cmd) && File.executable?(cmd)
print cmd
exit true
elsif ENV['PATH']
path = ENV['PATH'].split(File::PATH_SEPARATOR).find do |p|
File.executable?(File.join(p, cmd))
end
executable = path && File.expand_path(cmd, path)
print executable
exit !!(executable && executable.start_with?("$bundle_dir"))
end
rescue LoadError
exit false
rescue StandardError
exit false
end
RUBY
}

function zbe-auto-bundle-exec-accept-line() {

    # return if not bundled
    local bundle_dir="$(zbe-get-bundle-dir)"
    [[ $bundle_dir == '' ]] && zle accept-line && return

    # trim and split into command and arguments
    local trimmed="$(echo $BUFFER | sed 's/^[ ][ ]*//' | sed 's/[ ][ ]*$//')"
    local command="${${trimmed}%% *}"
    local args="${${trimmed}#$command}"

    # unalias if alias is used
    local expanded="$(alias '$command')"
    if [[ "$expanded" != '' ]]; then
expanded="${${${${${expanded}#*=}}#\'}%\'}"
        command="${expanded%% *}"
        local expanded_args="${expanded#$command}"
        if [[ "$expanded_args" != '' ]]; then
args="$expanded_args $args"
        fi
fi

    # check command
    if $(zbe-is-exceptional "$command") || [[ ! "$command" =~ '^[[:alnum:]_-]+$' ]]; then
zle accept-line && return
fi

local be_cmd
    be_cmd="$($BUNDLE_EXEC_RUBY_COMMAND -e "$(zbe-bundler-driver)")"
    if (( $? == 0 )); then
if [[ "$BUNDLE_EXEC_EXPAND_ALIASE" == '' ]]; then
BUFFER="bundle exec $command$args"
        else
BUFFER="$be_cmd$args"
        fi
fi

zle accept-line
}

zle -N auto_bundle_exec_accept_line zbe-auto-bundle-exec-accept-line

# if ^M key is not bound
if [[ "$(bindkey '^M' | cut -d ' ' -f 2)" == "accept-line" ]]; then
bindkey '^M' auto_bundle_exec_accept_line
fi

# bind ^J if available
if [[ "$(bindkey '^J' | cut -d ' ' -f 2)" == "accept-line" ]]; then
bindkey '^J' auto_bundle_exec_accept_line
fi

