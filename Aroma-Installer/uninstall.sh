# Aroma Installer

# Backup selections to temp directory
for FILE in $UNITY$SYS/etc/$MODID/*.prop; do
  cp_ch -nn $FILE $TMPDIR/aroma/$(basename $FILE)
done
