#!/usr/bin/env bash
# see http://osxdaily.com/2011/08/25/disable-reopen-windows-when-logging-back-in-in-mac-os-x-lion-completely/

# to enable: defaults write com.apple.loginwindow LoginHook ~/suppress-reopen-apps-on-login.sh

# to disable: defaults delete com.apple.loginwindow LoginHook

rm ~/Library/Preferences/ByHost/com.apple.loginwindow.*