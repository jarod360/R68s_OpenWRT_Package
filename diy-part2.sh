#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

#移除不用软件包  
rm -rf feeds/luci/applications/luci-app-ttyd
rm -rf feeds/luci/applications/luci-app-msd_lite
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/libs/libwebsockets
rm -rf feeds/packages/utils/ttyd
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/multimedia/xupnpd
rm -rf feeds/small/chinadns-ng
rm -rf feeds/kenzo/luci-app-wechatpush
rm -rf feeds/kenzo/luci-app-alist
rm -rf feeds/passwall/luci-app-passwall
rm -rf feeds/passwall_packages/v2ray-plugin
rm -rf feeds/passwall_packages/sing-box

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

#添加额外插件
git clone --depth=1 https://github.com/jarod360/openwrt_ttyd package/openwrt_ttyd
git clone --depth=1 https://github.com/jarod360/openwrt_msd_lite package/openwrt_msd_lite
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git package/luci-app-serverchan
git clone --depth=1 https://github.com/jarod360/luci-app-xupnpd package/luci-app-xupnpd
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git_sparse_clone master https://github.com/coolsnowwolf/packages multimedia/xupnpd
git_sparse_clone master https://github.com/kenzok8/openwrt-packages luci-app-fileassistant
git_sparse_clone master https://github.com/kenzok8/small chinadns-ng
git_sparse_clone main https://github.com/xiaorouji/openwrt-passwall luci-app-passwall

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Jarod/g" package/lean/default-settings/files/zzz-default-settings

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改插件名字
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`

#　web登陆密码从password修改为空
# sed -i 's/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/root::0:0:99999:7:::/g' package/lean/default-settings/files/zzz-default-settings

#　编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=R68S-$(shell TZ=UTC-8 date "+%Y%m%d")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# Modify default IP
sed -i 's/192.168.0.254/10.0.0.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

#去除serverchan无效检测网址
sed -i 's|https://www.baidu.com https://www.qidian.com https://www.douban.com|https://www.baidu.com|g' package/luci-app-serverchan/root/usr/share/serverchan/serverchan

# 调整argon登录框为居中
sed -i "/.login-page {/i\\
.login-container {\n\
  margin: auto;\n\
  height: 620px\!important;\n\
  min-height: 420px\!important;\n\
  left: 0;\n\
  right: 0;\n\
  bottom: 0;\n\
  margin-left: auto\!important;\n\
  border-radius: 15px;\n\
  width: 350px\!important;\n\
}\n\
.login-form {\n\
  background-color: rgba(255, 255, 255, 0.4)\!important;\n\
  border-radius: 15px;\n\
}\n\
.login-form .brand {\n\
  margin: 15px auto\!important;\n\
}\n\
.login-form .form-login {\n\
    padding: 10px 50px\!important;\n\
}\n\
.login-form .errorbox {\n\
  padding: 10px\!important;\n\
}\n\
.login-form .cbi-button-apply {\n\
  margin: 15px auto\!important;\n\
}\n\
.input-group {\n\
  margin-bottom: 1rem\!important;\n\
}\n\
.input-group input {\n\
  margin-bottom: 0\!important;\n\
}\n\
.ftc {\n\
  bottom: 0\!important;\n\
}" package/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css
sed -i "s/margin-left: 0rem \!important;/margin-left: auto\!important;/g" package/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css

