# APK-Patcher: Recovery Flashable Zip
# osm0sis @ xda-developers

baksmali() {
  ANDROID_DATA=$ap ANDROID_ROOT=/system LD_LIBRARY_PATH=/system/lib dalvikvm -Xbootclasspath:/system/framework/core.jar:/system/framework/conscrypt.jar:/system/framework/apache-xml.jar -classpath $baksmali org.jf.baksmali.main -o classout $1;
  test $? != 0 && abort "Decompiling APK classes failed. Aborting...";
}
smali() {
  ANDROID_DATA=$ap ANDROID_ROOT=/system LD_LIBRARY_PATH=/system/lib dalvikvm -Xbootclasspath:/system/framework/core.jar:/system/framework/conscrypt.jar:/system/framework/apache-xml.jar -classpath $smali org.jf.smali.main -o classes.dex classout;
  test $? != 0 && abort "Rebuilding APK classes failed. Aborting...";
}
apktool_d() {
  ANDROID_DATA=$ap ANDROID_ROOT=/system LD_LIBRARY_PATH=/system/lib dalvikvm -Xbootclasspath:/system/framework/core.jar:/system/framework/conscrypt.jar:/system/framework/apache-xml.jar -classpath $apktool brut.apktool.Main d --frame-path $ap/framework --no-src -o resout $1;
  test $? != 0 && abort "Decoding APK resources failed. Aborting...";
}
apktool_b() {
  ANDROID_DATA=$ap ANDROID_ROOT=/system LD_LIBRARY_PATH=/system/lib dalvikvm -Xbootclasspath:/system/framework/core.jar:/system/framework/conscrypt.jar:/system/framework/apache-xml.jar -classpath $apktool brut.apktool.Main b --frame-path $ap/framework --aapt $bin/aapt --copy-original -o $1 resout;
  test $? != 0 && abort "Rebuilding APK resources failed. Aborting...";
}

# working directory variables
ap=`pwd`;
bin=$ap/tools;
patch=$ap/patch;
script=$ap/script;

# set up extracted files and directories
chmod -R 755 $bin $script $ap/*.sh;

# dexed bak/smali and apktool jars (via: dx --dex --output=classes.dex <file>.jar)
baksmali=$bin/baksmali-*-dexed.jar;
smali=$bin/smali-*-dexed.jar;
apktool=$bin/apktool_*-dexed.jar;

ui_print " ";
ui_print "- Running APK Patcher by osm0sis & djb77 @ xda-developers-";
ui_print " ";

ui_print "   Patching files...";
cd $ap;
for target in $apklist; do
  ui_print "   $target";
  apkname=$(basename $target .apk);

  # copy in target system file to patch
  sysfile=`find /system -mindepth 2 -name $target`;
  cp -fp $sysfile $ap;

  # file patches
  if [ -d $patch/$apkname ]; then
    mv $apkname.apk $apkname.zip;
    
    # delete unwanted files
    if [ -f $script/$apkname.sh ]; then
      ui_print "  Removing files...";
      . $script/$apkname.sh;
      for remove in $fileremove; do
        $bin/zip -d $apkname.zip $remove;
      done
    fi;
    
    # continue patching
    ui_print "  Inject files";
    cd $patch/$apkname;
    $bin/zip -r -9 $ap/$apkname.zip *;
    if [ -f resources.arsc ]; then
      $bin/zip -r -0 $ap/$apkname.zip resources.arsc;
    fi;
    cd $ap;
    mv $apkname.zip $apkname.apk;    
  fi;

  # zipalign updated file
  cp -f $target $apkname-preopt.apk;
  rm $target;
  $bin/zipalign -p 4 $apkname-preopt.apk $target;

  # copy patched file back to system
  cp_ch $ap/$target $UNITY$sysfile;
done;
ui_print " ";

# extra required non-patch changes
. $ap/extracmd.sh;

cd /
