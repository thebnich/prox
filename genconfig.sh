#!/usr/bin/env sh

root=$(whoami)
read -d '' plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>DebugRoot</key>
    <string>$root</string>
</dict>
</plist>
EOF
echo "$plist" > Prox/Prox/LocalConfig.plist
