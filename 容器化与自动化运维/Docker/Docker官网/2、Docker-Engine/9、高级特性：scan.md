[TOC]

漏洞扫描，是收费功能，从pro开始

> 可在docker pro、docker team的Docker桌面端或Hub的仪表盘查看snyk漏洞扫描结果

![[Pasted image 20210817000537.png]]

# 介绍
在Snyk引擎上运行本地镜像的漏洞扫描(dockerfile和镜像)，使用CLI来漏洞扫描和查看结果。扫描结果包括常见漏洞和暴露(CVE)的列表，并为CVE提供修复建议

**注意的是**
本地镜像的漏洞扫描是beat功能，命令和标识在后期版本可能会改变

# 安装
## Linux
1. 从Docker Engine20.10.6开始，才会作为docker-ce-li包的依赖项，自动安装
2. 在此之前都需要手动安装
[安装包下载](https://github.com/docker/scan-cli-plugin/releases)；
[手动安装方式](https://github.com/docker/scan-cli-plugin/releases)
![[Pasted image 20210817101723.png]]
[[Docker重点]]

## 桌面版
* docker桌面2.3.6.0版本及以上，已经包含，无须另外安装
* 登录[hub](https://hub.docker.com/)
*（可选） 可以为扫描创建Snyk帐户，或者将Snyk提供的额外的每月免费扫描，与你的Docker Hub帐户一起使用。


docker scan --version
输出scan的版本和snyk的版本

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
并没有详细结果
`docker scan hello-world`


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