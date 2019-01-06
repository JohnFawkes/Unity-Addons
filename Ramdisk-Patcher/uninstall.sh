uninstall_files $INFORD "~"
sed -i "/#$MODID-UnityIndicator/d" $RD/init.rc
. $INSTALLER/addon/Ramdisk-Patcher/ramdiskuninstall.sh
