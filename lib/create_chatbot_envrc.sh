# Read the Dockerfile and docker-compose.yml file and create the according direnv file

# Read the python version from the base Dockerfile image
PYTHON_VERSION=$(grep "FROM python" ~/src/chatbot-integration/src/Dockerfile | cut -d':' -f2 | cut -d'-' -f1)

# Create the chatbot_envrc.sh file with the python version
echo "use python $PYTHON_VERSION" > chatbot_envrc.sh
echo "" >> chatbot_envrc.sh
echo "watch_file src/requirements.txt" >> chatbot_envrc.sh
echo "requirements_sentinel=\$VIRTUAL_ENV/requirements_installed.sentinel" >> chatbot_envrc.sh
echo 'if [[ ! -f "$requirements_sentinel" || "src/requirements.txt" -nt "$requirements_sentinel" ]]; then' >> chatbot_envrc.sh
echo '    pip install -r src/requirements.txt' >> chatbot_envrc.sh
echo '    touch $requirements_sentinel' >> chatbot_envrc.sh
echo 'fi' >> chatbot_envrc.sh
echo "" >> chatbot_envrc.sh

# Read the environment variables names from the docker-compose.yml file using yq
# have to exclude the `=` and everything after it
BUILD_ARGS=$(yq -r '.. | .build?.args? | select(. != null) | .[]' ~/src/chatbot-integration/docker-compose.yml | cut -d'=' -f1)
ENV_VARS=$(yq -r '.. | .environment? | select(. != null) | .[]' ~/src/chatbot-integration/docker-compose.yml | cut -d'=' -f1)

# Remove $CT_UNITS_GIT_COMMIT since it's dynamic, and empty lines
ALL_VARS=$(echo -e "$BUILD_ARGS\n$ENV_VARS" | grep -v "CT_UNITS_GIT_COMMIT" | grep -v "^$"  | sort | uniq)

# For each environment variable, get the value from the current environment and add it to the chatbot_envrc.sh file if it exists
echo "$ALL_VARS" | while read -r VAR; do
    VALUE=$(printenv "$VAR")
    if [ -n "$VALUE" ]; then
        # Escape only unescaped dollar signs by replacing $ with \$, but not \$
        ESCAPED_VALUE=$(echo "$VALUE" | sed 's/\([^\\]\)\$/\1\\$/g; s/^\$/\\$/')
        echo "export $VAR=\"$ESCAPED_VALUE\"" >> chatbot_envrc.sh
    fi
done
