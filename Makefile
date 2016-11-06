XTENSA		?=

# Mac and linux
SDK_BASE	?= /tools/esp8266/sdk/ESP8266_NONOS_SDK
ESPTOOL		?= /tools/esp8266/esptool/esptool.py

# Windows with unofficial dev kit (default install location is C:/Espressif)
# SDK_BASE	?= C:/Espressif/ESP8266_SDK
# ESPTOOL	?= C:/Espressif/utils/ESP8266/esptool.py

SDK_LIBS 	:= -lc -lgcc -lhal -lphy -lpp -lnet80211 -lwpa -lmain -llwip -lcrypto -ljson
CC			:= $(XTENSA)xtensa-lx106-elf-gcc
LD			:= $(XTENSA)xtensa-lx106-elf-gcc
AR			:= $(XTENSA)xtensa-lx106-elf-ar

LDFLAGS		= -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static
CFLAGS 		= -g -Wpointer-arith -Wundef -Wl,-EL -fno-inline-functions -nostdlib\
			  -mlongcalls -mtext-section-literals -ffunction-sections -fdata-sections\
			  -fno-builtin-printf -DICACHE_FLASH\
			  -I.
LD_SCRIPT	= -T$(SDK_BASE)/ld/eagle.app.v6.ld

all: main.bin

main.bin: main.out
	$(ESPTOOL) elf2image $(ESPTOOL_FLASHDEF) main.out -o main
	
main.out: main.a
	@echo "LD $@"
	$(LD) -L$(SDK_BASE)/lib $(LD_SCRIPT) $(LDFLAGS) -L$(SDK_BASE)/lib -Wl,--start-group $(SDK_LIBS) main.a -Wl,--end-group -o main.out

main.a: main.o
	@echo "AR main.o"
	$(AR) cru main.a main.o rf_init.o
	
main.o:
	@echo "CC main.c & rf_init.c"
	$(CC) -I$(SDK_BASE)/include $(CFLAGS) -c main.c -o main.o
	$(CC) -I$(SDK_BASE)/include $(CFLAGS) -c rf_init.c -o rf_init.o
	
clean:
	rm -rf *.o *.bin *.a *.out

flash:
	$(ESPTOOL) --port /dev/tty.SLAB_USBtoUART \
			   --baud 480600 \
			   write_flash --flash_freq 40m --flash_mode dio --flash_size 32m \
			   0x00000 main0x00000.bin \
			   0x10000 main0x10000.bin \
			   0x3fc000 $(SDK_BASE)/bin/esp_init_data_default.bin

.PHONY: all clean