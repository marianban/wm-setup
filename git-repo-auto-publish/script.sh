#!/bin/bash

# paths can be relative to the current user that owns the crontab configuration

# $(which node) returns the path to the current node version
# either the one specified as `default` alias in NVM or a specific version set above
# executing `nvm use 4 1> /dev/null` here won't work!

LOCKDIR="./lockdir"

#Remove the lock directory
function cleanup {
    if [ ! -d "$LOCKDIR" ]; then
        echo "Lock directory '$LOCKDIR' does not exist, skipping cleanup"
        return
    fi
    max_retry=3
    counter=0
    until rmdir "$LOCKDIR";
    do
       sleep 1
       ((counter++))
       if [[ $counter -eq $max_retry ]]; then echo "Failed to remove lock directory '$LOCKDIR'!" && exit 1; fi
       echo "Trying again. Try #$counter"
    done
    echo "Finished"
}

if mkdir $LOCKDIR; then
    if [ -d $LOCKDIR ]; then
        #Ensure that if we "grabbed a lock", we release it
        #Works for SIGTERM and SIGINT(Ctrl-C)
        trap "cleanup" EXIT

        echo "Acquired lock, running"

        # Processing starts here
        pushd /home/build/files/git-repo-auto-publish
        $(which node) /home/build/files/git-repo-auto-publish/index.js
        popd
    else
        echo "Directory not create succesfully"
    fi
else
    echo "Could not create lock directory '$LOCKDIR'"
    exit 1
fi
