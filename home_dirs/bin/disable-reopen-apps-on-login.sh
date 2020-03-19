#!/bin/sh

###################
#
# Prevent applications for re-opening on login for all users. 
#
# see https://osxdaily.com/2011/08/25/disable-reopen-windows-when-logging-back-in-in-mac-os-x-lion-completely/
#
# Installation:
# 1. Place this script in /Library/LoginHooks/disable-reopen-apps-on-login.sh
# 2. Ensure it is owned by root and is executable.
# 3. Register the login hook with the following command (as root):
#    defaults write com.apple.loginwindow LoginHook /Library/LoginHooks/disable-reopen-apps-on-login.sh
#
##################

rm /Users/*/Library/Preferences/ByHost/com.apple.loginwindow.*

