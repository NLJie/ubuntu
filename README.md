## 简介 Ubuntu24.04 Jammy-X11

A set of shell scripts that will build GNU/Linux distribution rootfs image
for rockchip platform.

## 适用板卡

- 使用RK3568处理器的 DarkOS 板卡(不支持gnome桌面)

## 安装依赖

推荐使用Ubuntu24.04及以上版本主机构建根文件系统

* ubuntu 22.04 (Jammy-X11)

```
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## 构建 Ubuntu24.04镜像（仅支持64bit）

- lite：控制台版，无桌面
- xfce：桌面版，使用xfce桌面套件
- xfce-full：桌面版，使用xfce桌面套件+更多推荐软件包
- gnome：桌面版，使用gnome桌面套件
- gnome-full：桌面版，使用gnome桌面套件+更多推荐软件包


#### step1.构建基础 Ubuntu 系统。

```
# 运行以下脚本，根据提示选择要构建的版本
./mk-base-ubuntu.sh
```
#### step2.添加 rk overlay 层,并打包ubuntu-rootfs镜像

```
# 运行以下脚本，根据提示选择要构建处理器版本和ubuntu的版本
./mk-ubuntu-rootfs.sh
```

## 文件介绍

```bash
.
├── ch-mount.sh             # 系统挂载、卸载脚本
├── mk-base-ubuntu.sh       # 构建基础文件系统
├── mk-ubuntu-rootfs.sh     # 构建对应平台的文件系统镜像
├── overlay                 # 通用的darkos文件系统配置
├── overlay-rockchip        # 瑞芯微文件系统配置
├── packages                # 软件包
└── ubuntu-build-service
```