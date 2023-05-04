# Jamf

## ChromeUpdater.sh
### Google Chrome Update Script for macOS M1

This bash script checks for Google Chrome updates on macOS M1 systems, downloads the latest version if necessary, and prompts the user to restart Chrome to apply the update. Users can choose to restart Chrome immediately or delay the update notification.

### Features

- Checks if the installed Google Chrome version is the latest available version
- Downloads and installs the latest Google Chrome version for macOS M1 if needed
- Displays a pop-up window prompting the user to restart Chrome for the update
- Allows users to delay the update notification up to 20 times
- After 20 delays, only the "Restart" option is available to ensure the update is applied
