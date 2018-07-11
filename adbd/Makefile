# Copyright 2005 The Android Open Source Project
#
# Android.mk for adb
#
# adbd device daemon
# =========================================================

PROGRAM = adbd

SRCDIRS = ./
CFLAGS := -O2 -g -DADB_HOST=0 -Wall -Wno-unused-parameter -Werror
CFLAGS += -D_XOPEN_SOURCE -D_GNU_SOURCE
CFLAGS += -DALLOW_ADBD_ROOT=1
CFLAGS += -I. -I./include

#LDFLAGS = -llog -lcutils -lc -lmincrypt -lselinux

include ../rule.mk
