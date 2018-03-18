################################################################################
#
# rtl8723bs
#
################################################################################

RTL8723BS_NEEDS_SOURCES=$(shell read -r MAJ MIN \
	<<< $$(echo "$(BR2_LINUX_KERNEL_VERSION)" | \
	sed -nr 's/[^0-9]*([0-9]+)\.([0-9]+).*/\1 \2/p') && \
	[ "0$$MAJ" -lt 4 -o "0$$MAJ" -eq 4 -a "0$$MIN" -lt 12 ] && echo 1 ||echo 0)
ifeq ($(RTL8723BS_NEEDS_SOURCES),1)
RTL8723BS_VERSION = 11ab92d8ccd71c80f0102828366b14ef6b676fb2
else
RTL8723BS_VERSION = cc77e7b6092c54500058cd027b679421b9399905
endif

RTL8723BS_SITE = $(call github,hadess,rtl8723bs,$(RTL8723BS_VERSION))
RTL8723BS_LICENSE = GPL-2.0, proprietary (*.bin firmware blobs)

RTL8723BS_MODULE_MAKE_OPTS = \
	CONFIG_RTL8723BS=m \
	KVER=$(LINUX_VERSION_PROBED) \
	KSRC=$(LINUX_DIR)

RTL8723BS_BINS = rtl8723bs_ap_wowlan.bin rtl8723bs_wowlan.bin \
	rtl8723bs_bt.bin rtl8723bs_nic.bin

define RTL8723BS_CONDITIONAL_PATCH
	if [ $(RTL8723BS_NEEDS_SOURCES) -eq 1 ]; then \
		$(APPLY_PATCHES) $(@D) package/rtl8723bs 0001-rtl8723bs-add-debug-level-modparam.patch.conditional; \
	fi;
endef

RTL8723BS_POST_PATCH_HOOKS += RTL8723BS_CONDITIONAL_PATCH

define RTL8723BS_INSTALL_FIRMWARE
	$(foreach bin, $(RTL8723BS_BINS), \
		$(INSTALL) -D -m 644 $(@D)/$(bin) $(TARGET_DIR)/lib/firmware/rtlwifi/$(bin)
	)
endef
RTL8723BS_POST_INSTALL_TARGET_HOOKS += RTL8723BS_INSTALL_FIRMWARE

$(eval $(kernel-module))
$(eval $(generic-package))
