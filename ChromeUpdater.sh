#!/bin/bash

# Function to get the latest Google Chrome version number
get_latest_chrome_version() {
    curl -sS https://omahaproxy.appspot.com/all.json | grep -oP '(?<="version": ")[^"]+(?=", "os": "mac")'
}

# Function to get the installed Google Chrome version number
get_installed_chrome_version() {
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | awk '{print $3}'
}

latest_version=$(get_latest_chrome_version)
installed_version=$(get_installed_chrome_version)

# Check if the installed version is the latest version
if [[ $latest_version != $installed_version ]]; then
    # Download the latest Google Chrome for macOS M1
    curl -L -O "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"

    # Mount the dmg file
    hdiutil attach googlechrome.dmg

    # Install Google Chrome
    sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/

    # Detach the dmg file
    hdiutil detach "/Volumes/Google Chrome"

    # Remove the dmg file
    rm googlechrome.dmg

    # Create the AppleScript to handle the update pop-up
    APPLESCRIPT=$(cat <<'EOF'
    on run argv
        set popupCounter to 0
        set maxPopupCounter to 20
        set triggerFilePath to "/tmp/chrome_update_trigger"
        repeat until popupCounter is maxPopupCounter
            set remainingTries to maxPopupCounter - popupCounter
            display dialog "Google Chrome update is ready to install. Please restart Chrome. You can delay this message " & remainingTries & " more times." with title "Update Google Chrome" buttons {"Restart", "Later"} default button "Restart"
            set buttonPressed to button returned of result
            if buttonPressed is "Restart" then
                quitChromeAndUpdate()
                exit repeat
            else
                set popupCounter to popupCounter + 1
                if do shell script "test -e " & triggerFilePath & "; echo $?" is "0" then
                    do shell script "rm " & triggerFilePath
                else
                    delay 1800
                end if
            end if
        end repeat
        if popupCounter is maxPopupCounter then
            display dialog "Google Chrome update is mandatory. Please restart Chrome." with title "Update Google Chrome" buttons {"Restart"} default button "Restart"
            quitChromeAndUpdate()
        end if
    end run

    on quitChromeAndUpdate()
        tell application "Google Chrome" to quit
        delay 3
        do shell script "open -a 'Google Chrome'"
    end quitChromeAndUpdate
    EOF
    )

    # Run the AppleScript
    osascript -e "$APPLESCRIPT"
fi