# Volume Key Selector - Addon that allows the use of the volume keys to select option in the installer

## Instructions:
* Use $VKSEL variable whenever you want to call the volume key selection function. The function returns true if user selected vol up and false if vol down
Ex: if $VKSEL; then
      echo "true"
    else
      echo "false"
    fi
* If you want to use the bixby button on samsung galaxy devices, [check out this post here](https://forum.xda-developers.com/showpost.php?p=77908805&postcount=16) and modify the main.sh functions accordingly
    
## Included Binaries/Credits:
* keycheck compiled for arm by [someone755 @Github](https://github.com/someone755/kerneller/blob/master/extract/tools/keycheck)
