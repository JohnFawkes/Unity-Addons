# Ramdisk-Patcher

# Functions
flash_boot_image() {
  # Make sure all blocks are writable
  magisk --unlock-blocks 2>/dev/null
  case "$1" in
    *.gz) local COMMAND="magiskboot --decompress '$1' - 2>/dev/null";;
    *)    local COMMAND="cat '$1'";;
  esac
  if [ -b "$2" ]; then
    local BLOCK=true
    local s_size=`stat -c '%s' "$1"`
    local t_size=`blockdev --getsize64 "$2"`
    [ $s_size -gt $t_size ] && return 1
  else
    local BLOCK=false
  fi
  if $BOOTSIGNED; then
    ui_print "- Signing boot image"
    eval $COMMAND | $BOOTSIGNER /boot $1 $INSTALLER/common/unityfiles/tools/avb/verity.pk8 $INSTALLER/common/unityfiles/tools/avb/verity.x509.pem boot-new-signed.img
    ui_print "- Flashing new boot image"
    $BLOCK && dd if=/dev/zero of="$2" 2>/dev/null
    dd if=boot-new-signed.img of="$2"
  elif $BLOCK; then
    ui_print "- Flashing new boot image"
    eval $COMMAND | cat - /dev/zero 2>/dev/null | dd of="$2" bs=4096 2>/dev/null
  else
    ui_print "- Not block device, storing image"
    eval $COMMAND | dd of="$2" bs=4096 2>/dev/null
  fi
  return 0
}
unpack_ramdisk() {
  local PATHDIR BOOTDIR=$INSTALLER/common/unityfiles/boot
  cp -af $INSTALLER/common/unityfiles/tools/chromeos $BOOTDIR
  chmod -R 0755 $BOOTDIR
  find_boot_image
  ui_print " "
  [ -z $BOOTIMAGE ] && abort "   ! Unable to detect target image !"
  ui_print "   Checking boot image signature..."
  BOOTSIGNER="/system/bin/dalvikvm -Xbootclasspath:/system/framework/core-oj.jar:/system/framework/core-libart.jar:/system/framework/conscrypt.jar:/system/framework/bouncycastle.jar -Xnodex2oat -Xnoimage-dex2oat -cp $INSTALLER/common/unityfiles/tools/avb/BootSignature_Android.jar com.android.verity.BootSignature"
  RAMDISK=true; BOOTSIGNED=false; CHROMEOS=false
  mkdir -p $RD
  cd $BOOTDIR
  dd if=$BOOTIMAGE of=boot.img
  eval $BOOTSIGNER -verify boot.img 2>&1 | grep "VALID" && BOOTSIGNED=true
  $BOOTSIGNED && ui_print "   Boot image is signed with AVB 1.0"
  rm -f boot.img  
  magiskinit -x magisk magisk
  ui_print "   Unpacking boot image..."
  magiskboot --unpack "$BOOTIMAGE"
  case $? in
    1 ) ui_print "   ! Unable to unpack boot image !"; abort "   ! Aborting !";;
    2 ) ui_print "   ChromeOS boot image detected"; CHROMEOS=true;;
    3 ) ui_print "   ! Sony ELF32 format detected !"; abort "   ! Please use BootBridge from @AdrianDC to flash this mod";;
    4 ) ui_print "   ! Sony ELF64 format detected !"; abort "   ! Stock kernel cannot be patched, please use a custom kernel";;
  esac
  ui_print "   Checking ramdisk status..."
  magiskboot --cpio ramdisk.cpio test
  cd ramdisk
  magiskboot --cpio ../ramdisk.cpio "extract"
  cd /
  ui_print " "
}
repack_ramdisk() {
  ui_print "- Repacking ramdisk"
  cd $RD
  find . | cpio -H newc -o > ../ramdisk.cpio
  cd ..
  ui_print "- Repacking boot image"
  magiskboot --repack "$BOOTIMAGE" || abort "! Unable to repack boot image!"
  $CHROMEOS && sign_chromeos
  magiskboot --cleanup
  flash_boot_image new-boot.img "$BOOTIMAGE" || abort "! Insufficient partition size"
  rm -f new-boot.img
  cd /
}

# Load functions only if non-magisk install (use magisk ones if present)
if ! $MAGISK; then
  find_boot_image() {
    BOOTIMAGE=
    if [ ! -z $SLOT ]; then
      BOOTIMAGE=`find_block boot$SLOT ramdisk$SLOT`
    else
      BOOTIMAGE=`find_block boot ramdisk boot_a kern-a android_boot kernel lnx bootimg`
    fi
    if [ -z $BOOTIMAGE ]; then
      # Lets see what fstabs tells me
      BOOTIMAGE=`grep -v '#' /etc/*fstab* | grep -E '/boot[^a-zA-Z]' | grep -oE '/dev/[a-zA-Z0-9_./-]*' | head -n 1`
    fi
  }
  sign_chromeos() {
    ui_print "- Signing ChromeOS boot image"

    echo > empty
    ./chromeos/futility vbutil_kernel --pack new-boot.img.signed \
    --keyblock ./chromeos/kernel.keyblock --signprivate ./chromeos/kernel_data_key.vbprivk \
    --version 1 --vmlinuz new-boot.img --config empty --arch arm --bootloader empty --flags 0x1

    rm -f empty new-boot.img
    mv new-boot.img.signed new-boot.img
  }
fi

chmod -R 0755 $INSTALLER/addon/Ramdisk-Patcher
cp -R $INSTALLER/addon/External-Tools/tools $INSTALLER/common/unityfiles 2>/dev/null
cp -f $INSTALLER/common/unityfiles/tools/$ARCH32/magiskinit $INSTALLER/common/unityfiles/tools/$ARCH32/magiskpolicy
unpack_ramdisk

# Fix print stuff - test it out
