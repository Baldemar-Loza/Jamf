#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#       ZoomInstall.sh -- Installs or updates Zoom
#
# SYNOPSIS
#       sudo ZoomInstall.sh
#
####################################################################################################
#
# HISTORY
#
#       Version: 1.1
#
#       1.2 - Lukas Indre, 3.3.2021
#       Update for universal installer
#
#       1.1 - Shannon Johnson, 27.9.2019
#       Updated for new zoom numbering scheme
#       Fixed the repeated plist modifications
#   
#       1.0 - Shannon Johnson, 28.9.2018
#       (Adapted from the FirefoxInstall.sh script by Joe Farage, 18.03.2015)
#
####################################################################################################
# Script to download and install Zoom.
# Only works on Intel systems.
#
# Set preferences
hdvideo="true"
ssodefault="false"
ssohost=""

# Choose language (en-US, fr, de)
lang="en-US"
if [ "$4" != "" ] && [ "$lang" == "" ]; then
    lang=$4
else 
    lang="en-US"
fi

pkgfile="ZoomInstallerIT.pkg"
plistfile="us.zoom.config.plist"
logfile="/Library/Logs/ZoomInstallScript.log"
UNIVERSAL_BINARY_URL="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

# Download Zoom package to a temporary location
# Added -L flag to follow redirects
/usr/bin/curl -L -o /tmp/ZoomInstallerIT.pkg $UNIVERSAL_BINARY_URL

# Get OS version and adjust for use with the URL string
OSvers_URL=$(sw_vers -productVersion | sed 's/[.]/_/g')

# Set the User Agent string for use with curl
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

# Extract version information from the downloaded package
pkgutil --expand /tmp/ZoomInstallerIT.pkg /tmp/ZoomInstallerIT_expanded
downloaded_version=$(xmllint --xpath 'string(//pkg-info/@version)' /tmp/ZoomInstallerIT_expanded/zoomus.pkg/PackageInfo)
rm -rf /tmp/ZoomInstallerIT_expanded
echo "latest version is $downloaded_version"

# Get the version number of the currently-installed Zoom, if any.
if [ -e "/Applications/zoom.us.app" ]; then
    current_installed_version=$(/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleVersion)
    echo "Your current version is $current_installed_version"
else
    current_installed_version="none"
fi


# Compare versions and decide whether to install
if [ "$downloaded_version" != "$current_installed_version" ]; then
    echo "Installing new version $downloaded_version"
    
    # Construct the plist file for preferences
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
    <plist version=\"1.0\">
    <dict>
        <key>nogoogle</key>
        <string>0</string>
        <key>nofacebook</key>
        <string>1</string>
        <key>NoSSO</key>
        <string>1</string>
        <key>EnableAppleLogin</key>
        <string>0</string>
        <key>DisableLoginWithEmail</key>
        <string>0</string>
        <key>ZAutoSSOLogin</key>
        <false/>
        <key>ZDisableVideo</key>
        <true/>
        <key>ZAutoJoinVoip</key>
        <true/>
    </dict>
    </plist>" > /tmp/${plistfile}
    
    /usr/sbin/installer -pkg /tmp/ZoomInstallerIT.pkg -target /
else
    echo "Zoom is already up-to-date. Deleting downloaded package."
    
fi

#double check to see if the new version got updated
newlyinstalledver=$(/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleVersion)
if [ "${downloaded_version}" = "${newlyinstalledver}" ]; then
    /bin/echo "`date`: SUCCESS: Zoom has been updated to version ${newlyinstalledver}" >> ${logfile}
else
    /bin/echo "`date`: ERROR: Zoom update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
    /bin/echo "--" >> ${logfile}
    exit 1
fi

/bin/rm /tmp/ZoomInstallerIT.pkg
exit 0
