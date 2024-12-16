# Read the Dockerfile and create the according direnv file

# Read the build arguments from the Dockerfile
BUILD_ARGS=$(grep "ARG" ~/src/ct_openstudio/openstudio/Dockerfile | cut -d' ' -f2 | cut -d'=' -f1)

# Remove $CT_UNITS_GIT_COMMIT since it's dynamic, and empty lines
ALL_VARS=$(echo -e "$BUILD_ARGS" | grep -v "CT_UNITS_GIT_COMMIT" | grep -v "^$"  | sort | uniq)

# Clear the openstudio_envrc.sh file
> openstudio_envrc.sh
# For each environment variable, get the value from the current environment and add it to the openstudio_envrc.sh file if it exists
echo "$ALL_VARS" | while read -r VAR; do
    VALUE=$(printenv "$VAR")
    if [ -n "$VALUE" ]; then
        # Escape only unescaped dollar signs by replacing $ with \$, but not \$
        ESCAPED_VALUE=$(echo "$VALUE" | sed 's/\([^\\]\)\$/\1\\$/g; s/^\$/\\$/')
        echo "export $VAR=\"$ESCAPED_VALUE\"" >> openstudio_envrc.sh
    fi
done
