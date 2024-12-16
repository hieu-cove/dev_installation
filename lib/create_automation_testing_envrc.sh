# Create the automation_testing_envrc.sh file with the environment variables
echo "export CYPRESS_password=\"$CYPRESS_password\"" > automation_testing_envrc.sh
echo "export CYPRESS_adminPassword=\"$CYPRESS_adminPassword\"" >> automation_testing_envrc.sh
echo "export CYPRESS_MAILSLURP_API_KEY=\"$CYPRESS_MAILSLURP_API_KEY\"" >> automation_testing_envrc.sh
echo "export HUBSPOT_API_TOKEN=\"$HUBSPOT_API_TOKEN\"" >> automation_testing_envrc.sh
echo "export LAUNCH_DARKLY_AUTH_TOKEN=\"$LAUNCH_DARKLY_AUTH_TOKEN\"" >> automation_testing_envrc.sh
echo "export LAUNCH_DARKLY_STAGING_CLIENT_ID=\"$LAUNCH_DARKLY_STAGING_CLIENT_ID\"" >> automation_testing_envrc.sh
echo "export LAUNCH_DARKLY_PROD_CLIENT_ID=\"$LAUNCH_DARKLY_PROD_CLIENT_ID\"" >> automation_testing_envrc.sh
echo "export LAUNCH_DARKLY_PROJECT_KEY=\"$LAUNCH_DARKLY_PROJECT_KEY\"" >> automation_testing_envrc.sh
echo "export MONDAY_API_KEY=\"$MONDAY_API_KEY\"" >> automation_testing_envrc.sh
echo "" >> automation_testing_envrc.sh
