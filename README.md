# TomcatServiceInstaller

Tested on Ubuntu 20.04

This script makes easier the process of installing Tomcat 10.0.20 and basic configurations, including:
- Setting installation path
- Tomcatmgr user's password to access Tomcat's manager
- Manager's Max file size
- JVM's minimum memory value
- JVM's maximum memory value

If the main.sh file does not have execution permissions it is possible to grant them by running the following command:
chmod +x main.sh

The end result displays a Tomcat service configured and ready to use.

NOTE: For the execution of this script it is necessary to be ROOT user.
