# Logging - Addon that logs complete install process among other device info

## Instructions:
* Use the function collect_logs in your install.sh to package the logs into a tar.xz into the devices internal storage. The following line needs to be added to your terminal script, if using one, in order to use the logging code in it.

. $MODPATH/logging.sh

* The following information is collected
  - System and Vendor build.props
  - Installed modules
  - Installed files for your module
  - ResetProps (Getprops if non magisk)
  - Unity debug log
  - Magisk.log and log.bak

* The following functions can be called in your install.sh
  - log_print (ui_print to screen and to install log)
  - log_handler (echos to install log along with date and time)
    
## Credits:
* [@Didgeridoohan](https://forum.xda-developers.com/member.php?u=4667597) Without him this code is not possible. thanks for allowing me to use and modify
