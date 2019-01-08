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
  cp -f $ZIP /cache/$MODID.zip
  chmod -R 0755 $INSTALLER/addon/Aroma-Installer/tools
  $INSTALLER/addon/Aroma-Installer/tools/$ARCH32/zip -r -0 /cache/$MODID-Aroma.zip $INSTALLER/META-INF
  echo -e "install /cache/$MODID-Aroma.zip\ninstall /cache/$MODID.zip" > /cache/recovery/openrecoveryscript
  ui_print "   Will reboot and launch aroma installer"
  cleanup
  sleep 2
  reboot recovery
fi
