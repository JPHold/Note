[TOC]

支持overlay和overlay2这两种存储驱动程序

# 前提条件
overlay2需要内核4.0及以上

xfs文件系统上，设置d_type=true(**通过设置ftype为1**)，才会采用overlay和overlay2。

# 如何更换
