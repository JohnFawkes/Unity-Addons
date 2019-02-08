# External Tools
exec &> $INSTLOG
chmod -R 0755 $INSTALLER/addon/Logging
cp -R $INSTALLER/addon/Logging $INSTALLER/common/unityfiles 2>/dev/null
PATH=$INSTALLER/common/unityfiles/Logging/:$PATH
cp -f $INSTALLER/common/unityfiles/Logging/main.sh $UNITY/system/bin/logging.sh
chmod 0755 $UNITY/bin/logging.sh
chown 0.2000 $UNITY/system/bin/logging.sh

if $BOOTMODE; then
  SDCARD=/storage/emulated/0
else
  SDCARD=/data/media/0
fi

if [ -d /cache ]; then CACHELOC=/cache; else CACHELOC=/data/cache; fi

MODTITLE=$(grep_prop name $INSTALLER/module.prop)
VER=$(grep_prop version $INSTALLER/module.prop)
AUTHOR=$(grep_prop author $INSTALLER/module.prop)
INSTLOG=$MODPATH/$MODID-install.log
TMPLOG=$MODID_logs.log
TMPLOGLOC=$MODPATH/$MODID_logs

LOGGERS="
$CACHELOC/magisk.log
$CACHELOC/magisk.log.bak
$MODPATH/$MODID-install.log
$SDCARD/$MODID-debug.log
/data/adb/magisk_debug.log
"

log_handler() {
	echo "" >> $INSTLOG
	echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $INSTLOG 2>&1
}

log_start() {
if [ -f "$INSTLOG" ]; then
  truncate -s 0 $INSTLOG
else
  touch $INSTLOG
fi
  echo " " >> $INSTLOG 2>&1
  echo "    *********************************************" >> $INSTLOG 2>&1
  echo "    *              $MODTITLE                    *" >> $INSTLOG 2>&1
  echo "    *********************************************" >> $INSTLOG 2>&1
  echo "    *                   $VER                    *" >> $INSTLOG 2>&1
  echo "    *********************************************" >> $INSTLOG 2>&1
  echo "    *                $AUTHOR                    *" >> $INSTLOG 2>&1
  echo "    *********************************************" >> $INSTLOG 2>&1
  echo " " >> $INSTLOG 2>&1
  log_handler "Log start."
}

log_print() {
  ui_print "$1"
  log_handler "$1"
}

collect_logs() {
	log_handler "Collecting logs and information."
	# Create temporary directory
	mkdir -pv $TMPLOGLOC >> $INSTLOG 2>&1

	# Saving Magisk and module log files and device original build.prop
	for ITEM in $LOGGERS; do
		if [ -f "$ITEM" ]; then
			case "$ITEM" in
				*build.prop*)	BPNAME="build_$(echo $ITEM | sed 's|\/build.prop||' | sed 's|.*\/||g').prop"
				;;
				*)	BPNAME=""
				;;
			esac
			cp -af $ITEM ${TMPLOGLOC}/${BPNAME} >> $INSTLOG 2>&1
		else
			case "$ITEM" in
				*/cache)
					if [ "$CACHELOC" == "/cache" ]; then
						CACHELOCTMP=/cache
					else
						CACHELOCTMP=/data/cache
					fi
					ITEMTPM=$(echo $ITEM | sed 's|$CACHELOC|$CACHELOCTMP|')
					if [ -f "$ITEMTPM" ]; then
						cp -af $ITEMTPM $TMPLOGLOC >> $LOG 2>&1
					else
						log_handler "$ITEM not available."
					fi
        ;;
				*)	log_handler "$ITEM not available."
				;;
			esac
    fi
	done

# Saving the current prop values
if $MAGISK; then
  log_handler "RESETPROPS"
  echo "==========================================" >> $INSTLOG 2>&1
	resetprop >> $INSTLOG 2>&1
	log_print " Collecting Modules Installed "
  echo "==========================================" >> $INSTLOG 2>&1
  ls $MOUNTPATH >> $INSTLOG 2>&1
  log_print " Collecting Logs for Installed Files "
  echo "==========================================" >> $INSTLOG 2>&1
  log_handler "$(du -ah $MODPATH)" >> $INSTLOG 2>&1
  grep -r "$MODID" -B 1 $MODPATH >> $INSTLOG 2>&1
else
  log_handler "GETPROPS"
  echo "==========================================" >> $INSTLOG 2>&1
	getprop >> $INSTLOG 2>&1
fi

# Package the files
cd $CACHELOC
tar -zcvf $MODID_logs.tar.xz $MODID_logs >> $INSTLOG 2>&1

# Copy package to internal storage
mv -f $CACHELOC/$MODID_logs.tar.xz $SDCARD >> $INSTLOG 2>&1

if  [ -e $SDCARD/$MODID_logs.tar.xz ]; then
  log_print "$MODID_logs.tar.xz Created Successfully."
else
  log_print "Archive File Not Created. Error in Script. Please contact the Unity Team"
fi

# Remove temporary directory
rm -rf $TMPLOGLOC >> $INSTLOG 2>&1

log_handler "Logs and information collected."
}

log_start "Running Log script." >> $INSTLOG 2>&1

cp_ch 
