# Read the Dockerfile and create the according direnv file

# Read the node version from the base Dockerfile image
NODE_VERSION=$(grep "FROM node" ~/src/ct_node/node/Dockerfile | cut -d':' -f2 | cut -d'-' -f1)
# Read the build arguments from the Dockerfile
BUILD_ARGS=$(grep "ARG" ~/src/ct_node/node/Dockerfile | cut -d' ' -f2 | cut -d'=' -f1)

# Create the node_envrc.sh file with the node version
echo "export NODE_VERSIONS=~/.nvm/versions/node" > node_envrc.sh
echo "export NODE_VERSION_PREFIX='v'" >> node_envrc.sh
echo "use node $NODE_VERSION" >> node_envrc.sh
echo "" >> node_envrc.sh

# Export all NPM environment variables
NPM_VARS="NPM_EMAIL\nNPM_PASS\nNPM_TOKEN\nNPM_USER"

# Remove $CT_UNITS_GIT_COMMIT since it's dynamic, and empty lines
ALL_VARS=$(echo -e "$NPM_VARS\n$BUILD_ARGS" | grep -v "CT_UNITS_GIT_COMMIT" | grep -v "^$"  | sort | uniq)

# For each environment variable, get the value from the current environment and add it to the node_envrc.sh file if it exists
echo "$ALL_VARS" | while read -r VAR; do
    VALUE=$(printenv "$VAR")
    if [ -n "$VALUE" ]; then
        # Escape only unescaped dollar signs by replacing $ with \$, but not \$
        ESCAPED_VALUE=$(echo "$VALUE" | sed 's/\([^\\]\)\$/\1\\$/g; s/^\$/\\$/')
        echo "export $VAR=\"$ESCAPED_VALUE\"" >> node_envrc.sh
    fi
done
