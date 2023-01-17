# vless-replit

在Replit上使用Xray Core部署vless+ws+tls协议（推荐使用该组合）

**可能部分配置不算完善，但足以满足日常使用，配置内容仅供参考。**

## 注意

- **切勿滥用！账号封禁风险自负！网络流量每月有100GB软上限。**

  可用的免费资源越来越少，基本都被薅没了（可怜的Arukas和Heroku），尽量小流量自用，用来满足日常需求就好。

- **Free Plan的Repls只能设为Public，即任何人都能查看Repls下的文件，注意不要泄漏设定的path和uuid！**

- **尽量避免使用任何代理访问国内网站。在本配置中为满足一定的需求，没有直接block国内域名和ip，请注意理应在客户端中进行路由配置，绕过国内网站。**

## 部署

<a href="https://replit.com/github/jimmyli1014/vless-replit">
  <img alt="Run on Replit" src="https://replit.com/badge/github/andbruibm/reader-replit" />
</a><br/>

可参考以下项目部署部分，点击以上按钮进行部署。注意Secrets改为设置uuid和path变量。

可以使用CDN（例如Cloudflare），避免直连，可一定程度提高安全性。（对于Replit使用Google Cloud，其本身直连速度大部分情况可以满足，所以使用CDN可能不会加速，甚至会出现减速的情况，但还是推荐使用。）

https://raw.githubusercontent.com/wy580477/replit-trojan/main/README.md

```
客户端参考配置：
域名：{项目名}.{账户名}.repl.co（例：vless.xray.repl.co，其中账户名为xray，项目名为vless）
端口：443
流控：留空（必须为空，其他选项均是xtls的）
加密方式：none（一定是none，是为提醒vless本身没有加密，所以依赖tls）
传输协议：ws
伪装类型：none
路径：{Secrets中设定的path}?ed=2048（例：/example?ed=2048，在原有path后添加ed参数实现WebSocket 0-RTT，具体可参考https://github.com/XTLS/Xray-core/pull/375）
TLS: tls（在Replit中不能使用xtls，且xtls似乎有更明显的特征，在讨论中看到更多更容易被GFW发现；tls更贴近真实https流量，更为推荐）
uTLS(Fingerprint)：建议不留空（用以解决GFW利用tls握手时ClientHello指纹中固定的特征进行判断，更贴近正常浏览器的请求，提高隐匿性）
```

## 说明

- 使用Xray Core进行部署，同时使用Caddy 2进行HTTP伪装。

- Replit似乎不允许发送UDP请求，所以也无法使用其他DNS（DoH未测试，应该可以），由于实际运行在Google Cloud上，使用其本地DNS在安全性上应该也没问题。同时也发现，存在客户端（实测Android端V2rayNG）会通过vless发送DNS请求进行解析，解析完成后再使用ip进行请求，则会由于上述原因不能解析，不能用域名打开网页，无法正常使用；而其他客户端（实测PC端V2rayN，不理解同一作者的两个客户端会有该差异-_-||）则是直接用域名进行请求，交由服务器端自行解析，则不会出现该问题。所以在本配置中，将接收到的53端口UDP请求（一般均为DNS请求）使用路由转到Xray自带的DNS模块替代原DNS进行解析，解决以上问题。

## 鸣谢

- [Project X](https://github.com/XTLS/Xray-core)
- [Caddy 2](https://github.com/caddyserver/caddy)
