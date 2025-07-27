#!/bin/bash -e

### BEGIN INIT INFO
# Provides:          DarkOSInit
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:
# Short-Description: Init script for DarkOS boards
# Description:       Initializes dtb, uEnv and system config for DarkOS boards
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 获取 BOARD_ID 和 SOC_type
board_id() {
	if [ -f /etc/darkos_board_id ]; then
		BOARD_ID=$(cat /etc/darkos_board_id | tr -d '\n')
	else
		echo "Error: /etc/darkos_board_id not found!"
		exit 1
	fi

	SOC_type=$(cat /proc/device-tree/compatible | tr '\0' '\n' | grep -Eo 'rk3562|rk3506|rk3568|rk3576|rk3588' | head -n1)

	if [ -z "$SOC_type" ]; then
		echo "Error: Unsupported or undetected SoC type!"
		exit 1
	fi

	echo "Detected BOARD_ID: $BOARD_ID"
	echo "Detected SOC_type: $SOC_type"
}

# 根据 BOARD_ID 设置 dtb 和 uEnv 文件
board_info() {
	case "$1" in
		DarkOS-3562-A01)
			BOARD_NAME='DarkOS-3562-A01'
			BOARD_DTB='rk3562-darkos-a01.dtb'
			BOARD_uEnv='uEnvDarkOS3562A01.txt'
			;;

		DarkOS-3506-B01)
			BOARD_NAME='DarkOS-3506-B01'
			BOARD_DTB='rk3506-darkos-b01.dtb'
			BOARD_uEnv='uEnvDarkOS3506A01.txt'
			;;

		DarkOS-3568-A01)
			BOARD_NAME='DarkOS-3568-A01'
			BOARD_DTB='rk3568-darkos-generic.dtb'
			BOARD_uEnv='uEnvDarkOS3568A01.txt'
			;;
		# 1U 机箱项目板子
		DarkOS-3568-B01)
			BOARD_NAME='RockEnergy-3568-B01'
			BOARD_DTB='rk3568-rockenergy-r1.dtb'
			BOARD_uEnv='uEnvRockEnergy3568B01.txt'
			;;

		DarkOS-3576-D01)
			BOARD_NAME='DarkOS-3576-D01'
			BOARD_DTB='rk3576-darkos-d01.dtb'
			BOARD_uEnv='uEnvDarkOS3576A01.txt'
			;;

		DarkOS-3588-E01)
			BOARD_NAME='DarkOS-3588-E01'
			BOARD_DTB='rk3588-darkos-e01.dtb'
			BOARD_uEnv='uEnvDarkOS3588E01.txt'
			;;

		*)
			echo "Unknown BOARD_ID: $1"
			BOARD_NAME='DarkOS-Unknown'
			BOARD_DTB='generic-darkos.dtb'
			BOARD_uEnv='uEnvDarkOS.txt'
			;;
	esac

	echo "BOARD_NAME: $BOARD_NAME"
	echo "BOARD_DTB: $BOARD_DTB"
	echo "BOARD_uEnv: $BOARD_uEnv"
}

# 执行识别
board_id
board_info ${BOARD_ID}

# 等待 boot 分区设备准备就绪
until [ -e "/dev/disk/by-partlabel/boot" ]; do
	echo "Waiting for /dev/disk/by-partlabel/boot..."
	sleep 0.1
done

# 首次启动逻辑
if [ ! -e "/boot/boot_init" ]; then
	echo "[INFO] Detected first boot, performing initialization..."

	if [ ! -e "/dev/disk/by-partlabel/userdata" ]; then
		# 获取 root/boot 分区名
		if [ ! -L "/boot/rk-kernel.dtb" ]; then
			for x in $(cat /proc/cmdline); do
				case $x in
					root=*)
						Root_Part=${x#root=}
						;;
					boot_part=*)
						Boot_Part_Num=${x#boot_part=}
						;;
				esac
			done

			Boot_Part="${Root_Part::-1}${Boot_Part_Num}"
			# mount "$Boot_Part" /boot || true
			# echo "$Boot_Part  /boot  auto  defaults  0 2" >> /etc/fstab
			mount /dev/mmcblk0p2 /boot || true
			echo "/dev/mmcblk0p2  /boot  auto  defaults  0 2" >> /etc/fstab
		fi

		# 安装内核
		service lightdm stop || echo "skip stopping lightdm"
		apt install -fy --allow-downgrades /boot/kerneldeb/* || true
		apt-mark hold linux-headers-$(uname -r) linux-image-$(uname -r) || true

		# 链接 dtb 和 uEnv 文件
		ln -sf dtb/$BOARD_DTB /boot/rk-kernel.dtb
		ln -sf $BOARD_uEnv /boot/uEnv/uEnv.txt

		touch /boot/boot_init
		rm -f /boot/kerneldeb/*
		cp -f /boot/logo_kernel.bmp /boot/logo.bmp
		echo "[INFO] Rebooting to complete initialization..."
		reboot
	else
		# 用户完整系统存在 userdata 分区
		echo "PARTLABEL=oem      /oem      ext2  defaults  0 2" >> /etc/fstab
		echo "PARTLABEL=userdata /userdata ext2  defaults  0 2" >> /etc/fstab
		touch /boot/boot_init
	fi
fi
