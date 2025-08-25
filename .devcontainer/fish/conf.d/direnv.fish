# Direnv configuration
if type -q direnv
    direnv hook fish | source
    set -x DIRENV_LOG_FORMAT ""
end