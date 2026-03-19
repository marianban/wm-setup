#!/bin/bash

# NVM needs the ability to modify your current shell session's env vars,
# which is why it's a sourced function

# found in the current user's .bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# uncomment the line below if you need a specific version of node
# other than the one specified as `default` alias in NVM (optional)
# nvm use 4 1> /dev/null

nvm use 22 1> /dev/null

export AUTO_PUBLISH_STARTED_SSH_AGENT=0

if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" > /dev/null
	export AUTO_PUBLISH_STARTED_SSH_AGENT=1
fi

if ! ssh-add -l > /dev/null 2>&1; then
	ssh-add < /dev/null
fi
