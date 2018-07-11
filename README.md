---
layout: post
title: Porting adbd to embedded Linux arm A7
date: 2018-07-10 00:00:00 +0300
description: # Add post description (optional) 
img: # Add image post (optional)
tags: [FreeRtos] # add tag
---
## Change kernel config
## Porting adbd
adbd changed huge with Android new version, but I don't need so much feature, like: verification.  
so I porting adbd from [Android 5.0.1](https://android.googlesource.com/platform/system/core/+/android-5.0.1_r1/adb/)  
Linux Oops可以打出callstack，类似如下
```
[   58.287873] Kernel panic - not syncing: Fatal exception
[   58.293116] CPU0: stopping
[   58.295835] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D W       4.9.38 #2
[   58.302981] Hardware name: Artosyn Sirius Family
[   58.307604] Backtrace: 
[   58.310075] [<8010aa5c>] (dump_backtrace) from [<8010acf8>] (show_stack+0x18/0x1c)
[   58.317660]  r7:80c01f20 r6:600f0193 r5:00000000 r4:80c1354c
[   58.323337] [<8010ace0>] (show_stack) from [<80316998>] (dump_stack+0x84/0xa0)
[   58.330577] [<80316914>] (dump_stack) from [<8010c7b8>] (handle_IPI+0xd4/0x190)
[   58.337900]  r7:80c01f20 r6:00000000 r5:00000000 r4:80c289e0
[   58.343575] [<8010c6e4>] (handle_IPI) from [<80101464>] (gic_handle_irq+0x80/0x9c)
[   58.351161]  r7:80c136f8 r6:80c01f20 r5:80c03b28 r4:a0802000
[   58.356834] [<801013e4>] (gic_handle_irq) from [<8010b7b8>] (__irq_svc+0x58/0x74)
```
之所以能打出callstack主要是依靠CONFIG_KALLSYMS_ALL， 该宏会将编译生成的符号表加入到elf文件中
Oops时，通过SP和FP找到对应的stack frame，然后查符号表回溯出整个backtrace.
![SP_FP]({{site.baseurl}}/assets/img/sp-fp.png)

## Porting to FreeRTOS

* 移植kernel/kallsyms.c
* 移植scripts/kallsyms.c，并生成执行文件kallsyms
* 在Makefile中添加kallsyms到target.bin
  ```
  $(TARGET).bin: $(OBJ_S) $(OBJ_C) 
    @$(LD) $^ $(LDFLAGS)  -T$(LINK_SCRIPT) -o $(TARGET)_temp1.elf
    $(NM) -n $(TARGET)_temp1.elf | ./kallsyms --all-symbols --base-relative > kallsyms_temp1.S
    $(CC) $(CFLAGS) -c -o kallsyms_temp1.o kallsyms_temp1.S
    @$(LD) $^ kallsyms_temp1.o $(LDFLAGS)  -T$(LINK_SCRIPT) -o $(TARGET)_temp2.elf
    $(NM) -n $(TARGET)_temp2.elf | ./kallsyms --all-symbols --base-relative > kallsyms_temp2.S
    $(CC) $(CFLAGS) -c -o kallsyms_temp2.o kallsyms_temp2.S
    @$(LD) $^ kallsyms_temp2.o $(LDFLAGS)  -T$(LINK_SCRIPT) -o $(TARGET).elf
    $(OBJCOPY) -O binary $(TARGET).elf $@
    $(OBJDUMP) -D $(TARGET).elf > $(TARGET).dis
    $(NM) $(TARGET).elf > $(TARGET).map
  ```
具体含义是：
1. 生成elf
2. 生成elf对应的kallsyms
3. 将kallsyms编译为.o并加入到elf中
4. 生成第3步elf对应的kallsyms，这个kallsyms包含所有的符号表（也包含kallsyms这个模块本身的符号信息）
5. 将kallsyms编译为.o并加入到elf中
6. 通过elf生成.bin文件

<!---
![I and My friends]({{site.baseurl}}/assets/img/we-in-rest.jpg)
-->

