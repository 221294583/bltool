# bltool
bilibili工具
## 主体功能
在安卓上，以下功能需要先登录获取cookies，没有cookies的api请求会返回-352。
### 查询弹幕
目前可查单p视频弹幕，未测试多p视频。
### 下载视频
目前可下载单p视频，未测试多p视频。
## 菜单功能
### 登录
登录以获取cookies。

安卓上无法获取httponly请求，意味着无法下载会员视频或充电视频；在win上可以获取httponly的cookies。
### 设置
设置语言后无须冷启动，但是需要按几下按钮刷新页面。

配置文件会被迁移到`win: ./config/bili_login.json`或`android:/storage/emulated/0/config/bltool/`，可以修改键值，单不要随意删除配置文件里的键。如果修改后导致无法启动，直接删除配置文件然后启动应用即可，应用会把初始配置文件迁移到文件夹内。