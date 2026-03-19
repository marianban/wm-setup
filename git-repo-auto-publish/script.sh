#!/bin/bash

# paths can be relative to the current user that owns the crontab configuration

# $(which node) returns the path to the current node version
# either the one specified as `default` alias in NVM or a specific version set above
# executing `nvm use 4 1> /dev/null` here won't work!

if [ -f "$HOME/cronjob.env.sh" ]; then
    . "$HOME/cronjob.env.sh"
fi

LOCKDIR="./lockdir"

# Remove the lock directory and stop any transient ssh-agent started for this run.
function cleanup {
    if [ -d "$LOCKDIR" ]; then
        max_retry=3
        counter=0
        until rmdir "$LOCKDIR"; do
           sleep 1
           ((counter++))
           if [[ $counter -eq $max_retry ]]; then
               echo "Failed to remove lock directory '$LOCKDIR'!"
               break
           fi
           echo "Trying again. Try #$counter"
        done
    fi

    if [ "${AUTO_PUBLISH_STARTED_SSH_AGENT:-0}" = "1" ] && [ -n "$SSH_AGENT_PID" ]; then
        ssh-agent -k > /dev/null
    fi

    echo "Finished"
}

if mkdir "$LOCKDIR"; then
    if [ -d "$LOCKDIR" ]; then
        #Ensure that if we "grabbed a lock", we release it
        #Works for SIGTERM and SIGINT(Ctrl-C)
        trap "cleanup" EXIT

        echo "Acquired lock, running"

        # Processing starts here
        pushd "$HOME/files/git-repo-auto-publish"
        "$(which node)" "$HOME/files/git-repo-auto-publish/index.js"
        popd
    else
        echo "Directory not create successfully"
    fi
else
    echo "Could not create lock directory '$LOCKDIR'"
    exit 1
fi
