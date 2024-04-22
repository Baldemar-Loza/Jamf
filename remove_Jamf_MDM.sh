#!/bin/bash

# Remove all system profiles
for identifier in $(/usr/bin/profiles -L | awk "/attribute/" | awk '{print $4}'); do
    /usr/bin/profiles -R -p "$identifier" >/dev/null 2>&1
done

echo “System Profiles Gone!”


# Remove all profiles installed by MDM
/usr/local/jamf/bin/jamf removeMdmProfile

echo "MDM Profile Gone!"

# Remove JAMF Framework
/usr/local/jamf/bin/jamf removeFramework
echo "jamf binery Gone!"

# Remove all Configuration Profiles
rm -rf /var/db/ConfigurationProfiles/
echo "Configuration Profiles folder Gone!"

# Remove all Profiles
/usr/bin/profiles -D -f -v
echo "Profiles Gone!"

exit 0

#### To reinstall Jamf run the following command separately
#
##sudo profiles renew -type enrollment

