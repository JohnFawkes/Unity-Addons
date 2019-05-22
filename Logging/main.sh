# External Tools
grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
}

NVBASE=/data/adb
MODDIRNAME=modules_update
MODULEROOT=$NVBASE/$MODDIRNAME
MODID=`grep_prop id $TMPDIR/module.prop`
MODPATH=$MODULEROOT/$MODID
MOUNTEDROOT=$NVBASE/modules/$MODID
MODTITLE=$(grep_prop name $TMPDIR/module.prop)
VER=$(grep_prop version $TMPDIR/module.prop)
AUTHOR=$(grep_prop author $TMPDIR/module.prop)
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

if $BOOTMODE; then
  SDCARD=/storage/emulated/0
else
  SDCARD=/data/media/0
fi

if [ -d /cache ]; then CACHELOC=/cache; else CACHELOC=/data/cache; fi

chmod -R 0755 $TMPDIR/addon/Logging
cp -R $TMPDIR/addon/Logging $UF/tools 2>/dev/null
PATH=$UF/tools/Logging/:$PATH
cp_ch -f $UF/tools/Logging/main.sh $MODPATH/logging.sh
sed -i "1i $SHEBANG" $MODPATH/logging.sh
sed -i "s|\$TMPDIR|$MOUNTEDROOT|g" $MODPATH/logging.sh
sed -i "s|\$MODPATH|$MOUNTEDROOT|g" $MODPATH/logging.sh
sed -i "s|\$INSTLOG|\$LOG|g" $MODPATH/logging.sh
sed -i "39,50d" $MODPATH/logging.sh
chmod 0755 $MODPATH/logging.sh
chown 0.2000 $MODPATH/logging.sh

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

log_script_chk() {
	log_handler "$1"
	echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $INSTLOG 2>&1
}

get_file_value() {
	cat $1 | grep $2 | sed "s|.*$2||" | sed 's|\"||g'
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
						cp -af $ITEMTPM $TMPLOGLOC >> $INSTLOG 2>&1
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
  ls $MODULEROOT >> $INSTLOG 2>&1
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
