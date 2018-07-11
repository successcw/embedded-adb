## Change kernel config
* enable CONFIG_USB_F_ as you need
  ```
  CONFIG_USB_F_ACM=y
  CONFIG_USB_F_FS=y
  CONFIG_USB_U_SERIAL=y
  ```
* enable CONFIGFS as you need
  ```
  CONFIG_USB_CONFIGFS_ACM=y
  CONFIG_USB_CONFIGFS_F_FS=y
  CONFIG_USB_CONFIGFS_SERIAL=y
  ```
Please noted, don't enable legacy usb config if you use configfs.  

## Porting adbd
adbd changed huge with Android new version, but I don't need so much feature, like: verification.  
so I porting adbd from [Android 5.0.1](https://android.googlesource.com/platform/system/core/+/android-5.0.1_r1/adb/)  
I have commented unuseful code for compile error, the bellowing works well:  
* adb shell
* adb push
* adb pull  

you may need change rule.mk and adbd/Makefile when porting to your embedded system.  

## add usb enable to init process(rcS)
  ```
  mount -t configfs none /sys/kernel/config
  mkdir -p /sys/kernel/config/usb_gadget/g1
  sync
  echo "0xBBE" > /sys/kernel/config/usb_gadget/g1/idVendor
  echo "0xB002" > /sys/kernel/config/usb_gadget/g1/idProduct
  mkdir -p /sys/kernel/config/usb_gadget/g1/strings/0x409
  sync
  echo "ST12345678" > /sys/kernel/config/usb_gadget/g1/strings/0x409/serialnumber
  echo "COM" > /sys/kernel/config/usb_gadget/g1/strings/0x409/manufacturer
  echo "P1" > /sys/kernel/config/usb_gadget/g1/strings/0x409/product
  mkdir -p /sys/kernel/config/usb_gadget/g1/functions/acm.GS0
  mkdir -p /sys/kernel/config/usb_gadget/g1/functions/acm.GS1
  mkdir -p /sys/kernel/config/usb_gadget/g1/functions/ffs.adb
  mkdir -p /sys/kernel/config/usb_gadget/g1/configs/c.1/strings/0x409
  echo "2acm1adb" > /sys/kernel/config/usb_gadget/g1/configs/c.1/strings/0x409/configuration
  ln -s /sys/kernel/config/usb_gadget/g1/functions/acm.GS0 /sys/kernel/config/usb_gadget/g1/configs/c.1
  ln -s /sys/kernel/config/usb_gadget/g1/functions/acm.GS1 /sys/kernel/config/usb_gadget/g1/configs/c.1
  ln -s /sys/kernel/config/usb_gadget/g1/functions/ffs.adb /sys/kernel/config/usb_gadget/g1/configs/c.1
  mkdir -p /dev/usb-ffs/adb
  mkdir /dev/pts
  sync
  mount -t functionfs adb /dev/usb-ffs/adb
  adbd &
  mount devpts /dev/pts -t devpts
  sleep 1
  echo "60500000.dwc3" > /sys/kernel/config/usb_gadget/g1/UDC
  ```

## Driver
  * adb
   use common adb driver, refer to Drivers\universaladbdriver_v5.0.exe 
  * acm
   windows support acm by default, if not, please refer to Drivers\win7.inf or winxp.inf  

## PC adb
  * [windows](https://dl.google.com/android/repository/platform-tools_r23-windows.zip)
  * [mac](https://dl.google.com/android/repository/platform-tools_r23-macosx.zip)
  * [Linux](https://dl.google.com/android/repository/platform-tools_r23-linux.zip)

## windows shell error code
Use windows CMD and adb shell, there is error code when ls or TAB/Ctrl+C/BACKSPACE  
you can use [adbputty](https://github.com/sztupy/adbputty/downloads) instead of CMD to fix this problem.


