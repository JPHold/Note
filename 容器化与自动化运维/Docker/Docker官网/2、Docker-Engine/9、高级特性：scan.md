[TOC]

> 可在docker pro、docker team的Docker桌面端或Hub的仪表盘查看snyk漏洞扫描结果

![[Pasted image 20210817000537.png]]

# 介绍
二次开发Snyk，Snyk提供了界面操作，而Docker只有命令操作，估计是Docker跟Synk的商业合作，Synk提供了一些接口给Docker调用；两者区别如下：
1. Snyk目前开放的方式，只支持从hub扫描，**意味着需要将镜像上传到hub，假如我们的镜像包含源代码等私密文件，那就很危险了！！！**
2. docker提供扫描功能，**无须上传到hub，即可扫描漏洞**

在Snyk引擎上运行本地镜像的漏洞扫描(dockerfile和镜像)，使用CLI来漏洞扫描和查看结果。扫描结果包括常见漏洞和暴露(CVE)的列表，并为CVE提供修复建议。

**注意的是**
本地镜像的漏洞扫描是beat功能，命令和标识在后期版本可能会改变。

* **需要登录hub才可以使用（因此内网无法使用scan功能）**[[Docker重点]]

# 安装
## Linux
1. 从Docker Engine20.10.6开始，才会作为docker-ce-li包的依赖项，自动安装

2. 在此之前都需要手动安装
[安装包下载](https://github.com/docker/scan-cli-plugin/releases)；
[手动安装方式](https://github.com/docker/scan-cli-plugin/releases)
![[Pasted image 20210817101723.png]]
[[Docker重点]]

3. 登录hub 
`docker login`
![[Pasted image 20210817102548.png]]
（需要注意login hub，会将未加密的密码记录到本地，危险！！！）[[2021-08(33)]]

## 桌面版
* docker桌面2.3.6.0版本及以上，已经包含，无须另外安装
* 登录[hub](https://hub.docker.com/)
*（可选） 可以为扫描创建Snyk帐户，或者将Snyk提供的额外的每月免费扫描，与你的Docker Hub帐户一起使用。

## 测试是否安装成功
`docker scan --version`
输出scan的版本和snyk的版本
![[Pasted image 20210817102849.png]]

**注意的是**
scan默认安装synk。如果不可用时，可自己安装，最低版本必须是1.385.0


# 支持的属性

| 属性 | 描述 | 例子 |
| --- | --- | --- |
| --accept license |  |  |
| --dependency-tree |  |  |
| --exclude-base |  |  |
| -f, --file string |  |  |
| --json |  |  |
| --login |  |  |
| --reject-license |  |  |
| --severity string |  |  |
| --token string |  |  |
| --version |  |  |

# 怎么扫描

![[Pasted image 20210817095934.png]]
## 扫描已存在的镜像，支持镜像id或镜像名称
`docker scan redis`
```shell
[root@localhost ~]# docker scan redis

Testing redis...

✗ Low severity vulnerability found in util-linux/libuuid1
  Description: Integer Overflow or Wraparound
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-UTILLINUX-1534833
  Introduced through: util-linux/libuuid1@2.33.1-0.1, e2fsprogs@1.44.5-1+deb10u3, util-linux/mount@2.33.1-0.1, util-linux/fdisk@2.33.1-0.1, util-linux/libblkid1@2.33.1-0.1, util-linux@2.33.1-0.1, sysvinit/sysvinit-utils@2.93-8, util-linux/bsdutils@1:2.33.1-0.1, util-linux/libfdisk1@2.33.1-0.1, util-linux/libmount1@2.33.1-0.1, util-linux/libsmartcols1@2.33.1-0.1
  From: util-linux/libuuid1@2.33.1-0.1
  From: e2fsprogs@1.44.5-1+deb10u3 > util-linux/libuuid1@2.33.1-0.1
  From: e2fsprogs@1.44.5-1+deb10u3 > util-linux/libblkid1@2.33.1-0.1 > util-linux/libuuid1@2.33.1-0.1
  and 25 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in tar
  Description: Out-of-bounds Read
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-TAR-1063001
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > tar@1.30+dfsg-6
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in tar
  Description: CVE-2005-2541
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-TAR-312331
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > tar@1.30+dfsg-6
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in tar
  Description: NULL Pointer Dereference
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-TAR-341203
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > tar@1.30+dfsg-6
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in systemd/libsystemd0
  Description: Authentication Bypass
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-1291056
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in systemd/libsystemd0
  Description: Link Following
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-305144
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in systemd/libsystemd0
  Description: Missing Release of Resource after Effective Lifetime
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-542807
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in systemd/libsystemd0
  Description: Improper Input Validation
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-570991
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in shadow/passwd
  Description: Time-of-check Time-of-use (TOCTOU)
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SHADOW-306205
  Introduced through: shadow/passwd@1:4.5-1.1, adduser@3.118, shadow/login@1:4.5-1.1, util-linux/mount@2.33.1-0.1
  From: shadow/passwd@1:4.5-1.1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1
  From: shadow/login@1:4.5-1.1
  and 1 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in shadow/passwd
  Description: Incorrect Permission Assignment for Critical Resource
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SHADOW-306230
  Introduced through: shadow/passwd@1:4.5-1.1, adduser@3.118, shadow/login@1:4.5-1.1, util-linux/mount@2.33.1-0.1
  From: shadow/passwd@1:4.5-1.1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1
  From: shadow/login@1:4.5-1.1
  and 1 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in shadow/passwd
  Description: Access Restriction Bypass
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SHADOW-306250
  Introduced through: shadow/passwd@1:4.5-1.1, adduser@3.118, shadow/login@1:4.5-1.1, util-linux/mount@2.33.1-0.1
  From: shadow/passwd@1:4.5-1.1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1
  From: shadow/login@1:4.5-1.1
  and 1 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in shadow/passwd
  Description: Incorrect Permission Assignment for Critical Resource
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SHADOW-539852
  Introduced through: shadow/passwd@1:4.5-1.1, adduser@3.118, shadow/login@1:4.5-1.1, util-linux/mount@2.33.1-0.1
  From: shadow/passwd@1:4.5-1.1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1
  From: shadow/login@1:4.5-1.1
  and 1 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in perl/perl-base
  Description: Link Following
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PERL-327793
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > perl/perl-base@5.28.1-6+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in pcre3/libpcre3
  Description: Out-of-Bounds
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-345321
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in pcre3/libpcre3
  Description: Out-of-Bounds
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-345353
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in pcre3/libpcre3
  Description: Uncontrolled Recursion
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-345502
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in pcre3/libpcre3
  Description: Out-of-Bounds
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-345530
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in pcre3/libpcre3
  Description: Out-of-bounds Read
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-572368
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in openssl/libssl1.1
  Description: Cryptographic Issues
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-OPENSSL-374709
  Introduced through: openssl/libssl1.1@1.1.1d-0+deb10u6
  From: openssl/libssl1.1@1.1.1d-0+deb10u6
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in openssl/libssl1.1
  Description: Cryptographic Issues
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-OPENSSL-374996
  Introduced through: openssl/libssl1.1@1.1.1d-0+deb10u6
  From: openssl/libssl1.1@1.1.1d-0+deb10u6
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in lz4/liblz4-1
  Description: Out-of-bounds Write
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LZ4-473072
  Introduced through: lz4/liblz4-1@1.8.3-1+deb10u1, apt@1.8.2.3
  From: lz4/liblz4-1@1.8.3-1+deb10u1
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > lz4/liblz4-1@1.8.3-1+deb10u1
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8 > lz4/liblz4-1@1.8.3-1+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libtasn1-6
  Description: Resource Management Errors
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBTASN16-339585
  Introduced through: libtasn1-6@4.13-3, apt@1.8.2.3
  From: libtasn1-6@4.13-3
  From: apt@1.8.2.3 > gnutls28/libgnutls30@3.6.7-4+deb10u7 > libtasn1-6@4.13-3
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libsepol/libsepol1
  Description: Use After Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBSEPOL-1315628
  Introduced through: libsepol/libsepol1@2.8-1, adduser@3.118
  From: libsepol/libsepol1@2.8-1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1 > libsemanage/libsemanage1@2.8-2 > libsepol/libsepol1@2.8-1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libsepol/libsepol1
  Description: Out-of-bounds Read
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBSEPOL-1315630
  Introduced through: libsepol/libsepol1@2.8-1, adduser@3.118
  From: libsepol/libsepol1@2.8-1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1 > libsemanage/libsemanage1@2.8-2 > libsepol/libsepol1@2.8-1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libsepol/libsepol1
  Description: Use After Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBSEPOL-1315636
  Introduced through: libsepol/libsepol1@2.8-1, adduser@3.118
  From: libsepol/libsepol1@2.8-1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1 > libsemanage/libsemanage1@2.8-2 > libsepol/libsepol1@2.8-1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libsepol/libsepol1
  Description: Use After Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBSEPOL-1315642
  Introduced through: libsepol/libsepol1@2.8-1, adduser@3.118
  From: libsepol/libsepol1@2.8-1
  From: adduser@3.118 > shadow/passwd@1:4.5-1.1 > libsemanage/libsemanage1@2.8-2 > libsepol/libsepol1@2.8-1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libseccomp/libseccomp2
  Description: Access Restriction Bypass
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBSECCOMP-341044
  Introduced through: libseccomp/libseccomp2@2.3.3-4, apt@1.8.2.3
  From: libseccomp/libseccomp2@2.3.3-4
  From: apt@1.8.2.3 > libseccomp/libseccomp2@2.3.3-4
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in libgcrypt20
  Description: Use of a Broken or Risky Cryptographic Algorithm
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBGCRYPT20-391902
  Introduced through: libgcrypt20@1.8.4-5+deb10u1, apt@1.8.2.3
  From: libgcrypt20@1.8.4-5+deb10u1
  From: apt@1.8.2.3 > gnupg2/gpgv@2.2.12-1+deb10u1 > libgcrypt20@1.8.4-5+deb10u1
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8 > libgcrypt20@1.8.4-5+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in gnutls28/libgnutls30
  Description: Improper Input Validation
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GNUTLS28-340755
  Introduced through: gnutls28/libgnutls30@3.6.7-4+deb10u7, apt@1.8.2.3
  From: gnutls28/libgnutls30@3.6.7-4+deb10u7
  From: apt@1.8.2.3 > gnutls28/libgnutls30@3.6.7-4+deb10u7
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in gnupg2/gpgv
  Description: Use of a Broken or Risky Cryptographic Algorithm
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GNUPG2-535553
  Introduced through: gnupg2/gpgv@2.2.12-1+deb10u1, apt@1.8.2.3
  From: gnupg2/gpgv@2.2.12-1+deb10u1
  From: apt@1.8.2.3 > gnupg2/gpgv@2.2.12-1+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Double Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1078993
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Uncontrolled Recursion
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-338106
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Uncontrolled Recursion
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-338163
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Improper Input Validation
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-356371
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Resource Management Errors
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-356671
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Resource Management Errors
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-356735
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: CVE-2010-4051
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-356875
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Out-of-Bounds
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-452228
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Access Restriction Bypass
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-452267
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Use of Insufficiently Random Values
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-453375
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Information Exposure
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-453640
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Information Exposure
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-534995
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in glibc/libc-bin
  Description: Integer Underflow
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-564233
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in coreutils
  Description: Improper Input Validation
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-COREUTILS-317465
  Introduced through: coreutils@8.30-3
  From: coreutils@8.30-3
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in coreutils
  Description: Race Condition
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-COREUTILS-317494
  Introduced through: coreutils@8.30-3
  From: coreutils@8.30-3
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in bash
  Description: Improper Check for Dropped Privileges
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-BASH-536280
  Introduced through: bash@5.0-4
  From: bash@5.0-4
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Low severity vulnerability found in apt/libapt-pkg5.0
  Description: Improper Verification of Cryptographic Signature
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-APT-407502
  Introduced through: apt/libapt-pkg5.0@1.8.2.3, apt@1.8.2.3
  From: apt/libapt-pkg5.0@1.8.2.3
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3
  From: apt@1.8.2.3
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Medium severity vulnerability found in pcre3/libpcre3
  Description: Integer Overflow or Wraparound
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-PCRE3-572367
  Introduced through: meta-common-packages@meta
  From: meta-common-packages@meta > pcre3/libpcre3@2:8.39-12
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Medium severity vulnerability found in libgcrypt20
  Description: Race Condition
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBGCRYPT20-460489
  Introduced through: libgcrypt20@1.8.4-5+deb10u1, apt@1.8.2.3
  From: libgcrypt20@1.8.4-5+deb10u1
  From: apt@1.8.2.3 > gnupg2/gpgv@2.2.12-1+deb10u1 > libgcrypt20@1.8.4-5+deb10u1
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8 > libgcrypt20@1.8.4-5+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Medium severity vulnerability found in glibc/libc-bin
  Description: Loop with Unreachable Exit Condition ('Infinite Loop')
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1035462
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Medium severity vulnerability found in glibc/libc-bin
  Description: Out-of-bounds Read
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1055403
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ Medium severity vulnerability found in glibc/libc-bin
  Description: Out-of-Bounds
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-559181
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in systemd/libsystemd0
  Description: Privilege Chaining
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-345386
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in systemd/libsystemd0
  Description: Incorrect Privilege Assignment
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-SYSTEMD-345391
  Introduced through: systemd/libsystemd0@241-7~deb10u8, util-linux/bsdutils@1:2.33.1-0.1, apt@1.8.2.3, util-linux/mount@2.33.1-0.1, systemd/libudev1@241-7~deb10u8
  From: systemd/libsystemd0@241-7~deb10u8
  From: util-linux/bsdutils@1:2.33.1-0.1 > systemd/libsystemd0@241-7~deb10u8
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > systemd/libsystemd0@241-7~deb10u8
  and 4 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in libidn2/libidn2-0
  Description: Improper Input Validation
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-LIBIDN2-474100
  Introduced through: libidn2/libidn2-0@2.0.5-1+deb10u1, apt@1.8.2.3
  From: libidn2/libidn2-0@2.0.5-1+deb10u1
  From: apt@1.8.2.3 > gnutls28/libgnutls30@3.6.7-4+deb10u7 > libidn2/libidn2-0@2.0.5-1+deb10u1
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in glibc/libc-bin
  Description: Reachable Assertion
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1065768
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in glibc/libc-bin
  Description: Use After Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1296899
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in glibc/libc-bin
  Description: Integer Overflow or Wraparound
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-1315333
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in glibc/libc-bin
  Description: Out-of-bounds Write
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-559488
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in glibc/libc-bin
  Description: Use After Free
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GLIBC-559493
  Introduced through: glibc/libc-bin@2.28-10, meta-common-packages@meta
  From: glibc/libc-bin@2.28-10
  From: meta-common-packages@meta > glibc/libc6@2.28-10
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in gcc-8/libstdc++6
  Description: Information Exposure
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GCC8-347558
  Introduced through: gcc-8/libstdc++6@8.3.0-6, apt@1.8.2.3, meta-common-packages@meta
  From: gcc-8/libstdc++6@8.3.0-6
  From: apt@1.8.2.3 > gcc-8/libstdc++6@8.3.0-6
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > gcc-8/libstdc++6@8.3.0-6
  and 2 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)

✗ High severity vulnerability found in gcc-8/libstdc++6
  Description: Insufficient Entropy
  Info: https://snyk.io/vuln/SNYK-DEBIAN10-GCC8-469413
  Introduced through: gcc-8/libstdc++6@8.3.0-6, apt@1.8.2.3, meta-common-packages@meta
  From: gcc-8/libstdc++6@8.3.0-6
  From: apt@1.8.2.3 > gcc-8/libstdc++6@8.3.0-6
  From: apt@1.8.2.3 > apt/libapt-pkg5.0@1.8.2.3 > gcc-8/libstdc++6@8.3.0-6
  and 2 more...
  Image layer: Introduced by your base image (redis:6.2.5-buster)



Package manager:   deb
Project name:      docker-image|redis
Docker image:      redis
Platform:          linux/amd64
Base image:        redis:6.2.5-buster

Tested 87 dependencies for known vulnerabilities, found 62 vulnerabilities.

According to our scan, you are currently using the most secure version of the selected base image

For more free scans that keep your images secure, sign up to Snyk at https://dockr.ly/3ePqVcp
```

## 扫描Dockerfile，获得详细结果
`docker scan --file PATH_TO_DOCKERFILE DOCKER_IMAGE`
docker scan --file Dockerfile docker-scan:e2e


### --exclude-base不扫描某个镜像
`docker scan --file Dockerfile --exclude-base docker-scan:e2e`


## 指定输出格式
### JSON输出格式
`docker scan --json hello-world`
```shell

$ docker scan --json hello-world
{
  "vulnerabilities": [],
  "ok": true,
  "dependencyCount": 0,
  "org": "docker-desktop-test",
  "policy": "# Snyk (https://snyk.io) policy file, patches or ignores known vulnerabilities.\nversion: v1.19.0\nignore: {}\npatch: {}\n",
  "isPrivate": true,
  "licensesPolicy": {
    "severities": {},
    "orgLicenseRules": {
      "AGPL-1.0": {
        "licenseType": "AGPL-1.0",
        "severity": "high",
        "instructions": ""
      },
      ...
      "SimPL-2.0": {
        "licenseType": "SimPL-2.0",
        "severity": "high",
        "instructions": ""
      }
    }
  },
  "packageManager": "linux",
  "ignoreSettings": null,
  "docker": {
    "baseImageRemediation": {
      "code": "SCRATCH_BASE_IMAGE",
      "advice": [
        {
          "message": "Note that we do not currently have vulnerability data for your image.",
          "bold": true,
          "color": "yellow"
        }
      ]
    },
    "binariesVulns": {
      "issuesData": {},
      "affectedPkgs": {}
    }
  },
  "summary": "No known vulnerabilities",
  "filesystemPolicy": false,
  "uniqueCount": 0,
  "projectName": "docker-image|hello-world",
  "path": "hello-world"
 }
```

如果只想输出一次漏洞结果，可使用--group-issues
docker scan --json --group-issues docker-scan:e2e
从结果中的from属性找到漏洞所属镜像
```shell
$ docker scan --json --group-issues docker-scan:e2e
{
    {
      "title": "Improper Check for Dropped Privileges",
      ...
      "packageName": "bash",
      "language": "linux",
      "packageManager": "debian:10",
      "description": "## Overview\nAn issue was discovered in disable_priv_mode in shell.c in GNU Bash through 5.0 patch 11. By default, if Bash is run with its effective UID not equal to its real UID, it will drop privileges by setting its effective UID to its real UID. However, it does so incorrectly. On Linux and other systems that support \"saved UID\" functionality, the saved UID is not dropped. An attacker with command execution in the shell can use \"enable -f\" for runtime loading of a new builtin, which can be a shared object that calls setuid() and therefore regains privileges. However, binaries running with an effective UID of 0 are unaffected.\n\n## References\n- [CONFIRM](https://security.netapp.com/advisory/ntap-20200430-0003/)\n- [Debian Security Tracker](https://security-tracker.debian.org/tracker/CVE-2019-18276)\n- [GitHub Commit](https://github.com/bminor/bash/commit/951bdaad7a18cc0dc1036bba86b18b90874d39ff)\n- [MISC](http://packetstormsecurity.com/files/155498/Bash-5.0-Patch-11-Privilege-Escalation.html)\n- [MISC](https://www.youtube.com/watch?v=-wGtxJ8opa8)\n- [Ubuntu CVE Tracker](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2019-18276)\n",
      "identifiers": {
        "ALTERNATIVE": [],
        "CVE": [
          "CVE-2019-18276"
        ],
        "CWE": [
          "CWE-273"
        ]
      },
      "severity": "low",
      "severityWithCritical": "low",
      "cvssScore": 7.8,
      "CVSSv3": "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H/E:F",
      ...
      "from": [
        "docker-image|docker-scan@e2e",
        "bash@5.0-4"
      ],
      "upgradePath": [],
      "isUpgradable": false,
      "isPatchable": false,
      "name": "bash",
      "version": "5.0-4"
    },
    ...
    "summary": "880 vulnerable dependency paths",
      "filesystemPolicy": false,
      "filtered": {
        "ignore": [],
        "patch": []
      },
      "uniqueCount": 158,
      "projectName": "docker-image|docker-scan",
      "platform": "linux/amd64",
      "path": "docker-scan:e2e"
}
```

* 获得镜像的依赖树
在扫描漏洞前，先解析出依赖树
docker scan --dependency-tree debian:buster
```shell

$ docker scan --dependency-tree debian:buster

$ docker-image|99138c65ebc7 @ latest
     ├─ ca-certificates @ 20200601~deb10u1
     │  └─ openssl @ 1.1.1d-0+deb10u3
     │     └─ openssl/libssl1.1 @ 1.1.1d-0+deb10u3
     ├─ curl @ 7.64.0-4+deb10u1
     │  └─ curl/libcurl4 @ 7.64.0-4+deb10u1
     │     ├─ e2fsprogs/libcom-err2 @ 1.44.5-1+deb10u3
     │     ├─ krb5/libgssapi-krb5-2 @ 1.17-3
     │     │  ├─ e2fsprogs/libcom-err2 @ 1.44.5-1+deb10u3
     │     │  ├─ krb5/libk5crypto3 @ 1.17-3
     │     │  │  └─ krb5/libkrb5support0 @ 1.17-3
     │     │  ├─ krb5/libkrb5-3 @ 1.17-3
     │     │  │  ├─ e2fsprogs/libcom-err2 @ 1.44.5-1+deb10u3
     │     │  │  ├─ krb5/libk5crypto3 @ 1.17-3
     │     │  │  ├─ krb5/libkrb5support0 @ 1.17-3
     │     │  │  └─ openssl/libssl1.1 @ 1.1.1d-0+deb10u3
     │     │  └─ krb5/libkrb5support0 @ 1.17-3
     │     ├─ libidn2/libidn2-0 @ 2.0.5-1+deb10u1
     │     │  └─ libunistring/libunistring2 @ 0.9.10-1
     │     ├─ krb5/libk5crypto3 @ 1.17-3
     │     ├─ krb5/libkrb5-3 @ 1.17-3
     │     ├─ openldap/libldap-2.4-2 @ 2.4.47+dfsg-3+deb10u2
     │     │  ├─ gnutls28/libgnutls30 @ 3.6.7-4+deb10u4
     │     │  │  ├─ nettle/libhogweed4 @ 3.4.1-1
     │     │  │  │  └─ nettle/libnettle6 @ 3.4.1-1
     │     │  │  ├─ libidn2/libidn2-0 @ 2.0.5-1+deb10u1
     │     │  │  ├─ nettle/libnettle6 @ 3.4.1-1
     │     │  │  ├─ p11-kit/libp11-kit0 @ 0.23.15-2
     │     │  │  │  └─ libffi/libffi6 @ 3.2.1-9
     │     │  │  ├─ libtasn1-6 @ 4.13-3
     │     │  │  └─ libunistring/libunistring2 @ 0.9.10-1
     │     │  ├─ cyrus-sasl2/libsasl2-2 @ 2.1.27+dfsg-1+deb10u1
     │     │  │  └─ cyrus-sasl2/libsasl2-modules-db @ 2.1.27+dfsg-1+deb10u1
     │     │  │     └─ db5.3/libdb5.3 @ 5.3.28+dfsg1-0.5
     │     │  └─ openldap/libldap-common @ 2.4.47+dfsg-3+deb10u2
     │     ├─ nghttp2/libnghttp2-14 @ 1.36.0-2+deb10u1
     │     ├─ libpsl/libpsl5 @ 0.20.2-2
     │     │  ├─ libidn2/libidn2-0 @ 2.0.5-1+deb10u1
     │     │  └─ libunistring/libunistring2 @ 0.9.10-1
     │     ├─ rtmpdump/librtmp1 @ 2.4+20151223.gitfa8646d.1-2
     │     │  ├─ gnutls28/libgnutls30 @ 3.6.7-4+deb10u4
     │     │  ├─ nettle/libhogweed4 @ 3.4.1-1
     │     │  └─ nettle/libnettle6 @ 3.4.1-1
     │     ├─ libssh2/libssh2-1 @ 1.8.0-2.1
     │     │  └─ libgcrypt20 @ 1.8.4-5
     │     └─ openssl/libssl1.1 @ 1.1.1d-0+deb10u3
     ├─ gnupg2/dirmngr @ 2.2.12-1+deb10u1
    ...

Organization:      docker-desktop-test
Package manager:   deb
Project name:      docker-image|99138c65ebc7
Docker image:      99138c65ebc7
Licenses:          enabled

Tested 200 dependencies for known issues, found 157 issues.

For more free scans that keep your images secure, sign up to Snyk at https://dockr.ly/3ePqVcp.
```
更多关于漏洞数据的信息，[Docker Vulnerability Scanning CLI Cheat Sheet](https://goto.docker.com/rs/929-FJL-178/images/cheat-sheet-docker-desktop-vulnerability-scanning-CLI.pdf)

* 限制查看漏洞的严重程度
关心某个等级及以上的漏洞，通过--severity(low、medium、high)来限制
docker scan --severity=medium docker-scan:e2e

# 安全认证
如果有snyk帐号，可以直接使用Snyk的[API token](https://app.snyk.io/account)
**如果只使用--login，会重定向到Synk网站进行登录**

# issue
WSL2
* Alpine版本并不支持漏洞扫描
* 如果使用Debian和OpenSUSE系统，那么登录必须携带--token，并不会重定向到Synk网站进行登录

# 反馈
可在[scan-cli-plugin的Github项目](https://github.com/docker/cli-scan-feedback/issues/new)中创建issue