#!/bin/sh

#  increment-build.sh
#  GlitchRun
#
#  Created by David Wilkinson on 09/08/2011.


processedPlist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
projectPlist="${INFOPLIST_FILE}"
versionVar="CFBundleVersion"

buildNumber=$(/usr/libexec/PlistBuddy -c "Print ${versionVar}" "${projectPlist}" 2>&1)
if [[ "$buildNumber" == *Does\ Not\ Exist ]] ; then
buildNumber=1
echo "Create ${versionVar} and set to ${buildNumber}"
/usr/libexec/PlistBuddy -c "Add :${versionVar} String ${buildNumber}" "${processedPlist}"
/usr/libexec/PlistBuddy -c "Add :${versionVar} String ${buildNumber}" "${projectPlist}"
else
buildNumber=$(($buildNumber + 1))
echo "set ${versionVar} to ${buildNumber}"
/usr/libexec/PlistBuddy -c "Set :${versionVar} ${buildNumber}" "${processedPlist}"
/usr/libexec/PlistBuddy -c "Set :${versionVar} ${buildNumber}" "${projectPlist}"
fi