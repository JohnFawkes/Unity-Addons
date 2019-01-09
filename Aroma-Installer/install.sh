# Aroma Installer

if [ -d "/cache/$MODID" ]; then
  ui_print "   Continuing install with aroma options"
  # Save selections to Mod
  for i in /cache/$MODID/*.prop; do
    cp_ch -n $i $UNITY/system/etc/$MODID/$(basename $i)
  done
  rm -f /cache/$MODID.zip /cache/$MODID-Aroma.zip /cache/recovery/openrecoveryscript
  rm -rf /cache/$MODID
else
  if [ -d "$TMPDIR/aroma" ]; then
    # Move previous selections to temp directory for reuse if chosen
    ui_print "   Backup up previous selections..."
    for FILE in $TMPDIR/aroma/*.prop; do
      cp_ch -nn $FILE /cache/$MODID/$(basename $FILE)
    done
  fi
  ui_print "   Creating Aroma installer and open recovery script..."
  cp -f $ZIPFILE /cache/$MODID.zip
  cd $INSTALLER/addon/Aroma-Installer
  sed -i "2i MODID=$MODID" META-INF/com/google/android/update-binary-installer
  chmod -R 0755 tools
  cp -R $INSTALLER/addon/Aroma-Installer/tools $INSTALLER/common/unityfiles 2>/dev/null
  zip -qr0 /cache/$MODID-Aroma META-INF
  cd /
  echo -e "install /cache/$MODID-Aroma.zip\ninstall /cache/$MODID.zip\nreboot recovery" > /cache/recovery/openrecoveryscript
  ui_print "   Will reboot and launch aroma installer"
  cleanup
  sleep 2
  reboot recovery
fi
