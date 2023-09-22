# Parse logs


Here you can find scripts to help you check the system load.

# parseThingsboardLog 
The script allows you to find the average and maximum number of processed, saved, failed, etc. messages in the log file for different queues

By default the script uses the thingsboard.log file which is located in the folder with the script. you can change the path to this file in the LOGS_PATH variable of the script itself, or set the path when the script runs. For example:
`./parseThingsboardLog ~/path/to/logs/thingsboard_log_name.log`

# createQueryForFailedRuleNodes
The script finds all nodes that failed to initialise when the service was started and creates a database query template. After executing this query, you will see all nodes with initialisation errors. You can then easily find and troubleshoot them.
Specify the log file in the `LOG_FILE` variable.