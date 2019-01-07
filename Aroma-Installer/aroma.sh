# Aroma Installer

ZIPNAME=

# Add TWRP detection here - abort if no twrp

if $BOOTMODE; then SDCARD=/storage/emulated/0; else SDCARD=/data/media/0; fi

if [ -f $SDCARD/$MODID-Aroma.zip ]; then
  # If aroma is completed condition, continue. Abort otherwise
  ui_print "   Continuing install with aroma options"
  rm -f $SDCARD/$MODID-Aroma.zip /cache/recovery/openrecoveryscript
else
  ui_print "   Creating Aroma installer and open recovery script..."
  chmod -R 0755 $INSTALLER/addon/Aroma-Installer/tools
  $INSTALLER/addon/Aroma-Installer/tools/$ARCH32/zip -r -0 $SDCARD/$MODID-Aroma.zip $INSTALLER/META-INF
  echo -e "install /data/media/0/$MODID-Aroma.zip\ninstall /data/media/0/$ZIPNAME" > /cache/recovery/openrecoveryscript
  ui_print "   Will reboot and launch aroma installer"
  cleanup
  sleep 2
  reboot recovery
fi
