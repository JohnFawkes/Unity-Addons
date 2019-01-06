rm -f $INSTALLER/addon/Ramdisk-Patcher/ramdisk/placeholder
# Remove ramdisk mod if exists
if [ "$(grep "#$MODID-UnityIndicator" $RD/init.rc 2>/dev/null)" ]; then
  ui_print " "
  ui_print "   ! Mod detected in ramdisk!"
  ui_print "   ! Upgrading mod ramdisk modifications..."
  uninstall_files $INFORD
  sed -i "/#$MODID-UnityIndicator/d" $RD/init.rc
  . $INSTALLER/addon/Ramdisk-Patcher/ramdiskuninstall.sh
fi
# Script to remove mod from system/magisk in event mod is only removed from ramdisk (like dirty flashing)
cp -f $INSTALLER/addon/Ramdisk-Patcher/modidramdisk.sh $INSTALLER/common/unityfiles/$MODID-ramdisk.sh
sed -i -e "/# CUSTOM USER SCRIPT/ r $INSTALLER/common/uninstall.sh" -e '/# CUSTOM USER SCRIPT/d' $INSTALLER/common/unityfiles/$MODID-ramdisk.sh
install_script -p $INSTALLER/common/unityfiles/$MODID-ramdisk.sh
# Use comment as install indicator
echo "#$MODID-UnityIndicator" >> $RD/init.rc
. $INSTALLER/addon/Ramdisk-Patcher/ramdiskinstall.sh
for FILE in $(find $INSTALLER/addon/Ramdisk-Patcher/ramdisk -type f 2>/dev/null | sed "s|$INSTALLER/addon/Ramdisk-Patcher||" 2>/dev/null); do
  cp_ch $INSTALLER/addon/Ramdisk-Patcher/$FILE $INSTALLER/common/unityfiles/boot$FILE
done
[ ! -s $INFORD ] && rm -f $INFORD
