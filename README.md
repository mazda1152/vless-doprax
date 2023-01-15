# vless-replit

在Replit上使用Xray Core部署vless+ws+tls协议（推荐使用该组合），目标在安全/稳定性和性能上均得到最优解。

**第一次进行完整配置，可能部分配置不算完善，但可以满足日常使用，配置内容仅供参考。** 

## 注意

**切勿滥用！账号封禁风险自负！网络流量每月有100GB软上限。**

可用的免费资源越来越少了，基本都被薅没（可怜的Heroku），尽量小流量自用，用来满足日常需求就好。

## 部署

<a href="https://replit.com/github/jimmyli1014/vless-replit">
  <img alt="Run on Replit" src="https://replit.com/badge/github/andbruibm/reader-replit" />
</a><br/>

可参考以下项目部署部分，点击以上按钮进行部署，注意Secrets改为设置uuid和path变量。

https://raw.githubusercontent.com/wy580477/replit-trojan/main/README.md

## 说明

- 使用Xray Core进行部署，同时使用Caddy 2进行HTTP伪装。

- Replit似乎不允许发送UDP请求，所以也无法使用其他DNS（DoH未测试，应该可以），由于实际运行在Google Cloud上，使用其本地DNS在安全性上应该也没问题。同时也发现，存在客户端（实测Android端V2rayNG）会通过vless发送DNS请求进行解析，解析完成后再使用ip进行请求，则会由于上述原因不能解析，不能用域名打开网页，无法正常使用；而其他客户端（实测PC端V2rayN，不理解同一作者的两个客户端会有该差异-_-||）则是直接用域名进行请求，交由服务器端自行解析，则不会出现该问题。所以在本配置中，将接收到的53端口UDP请求（一般均为DNS请求）使用路由转到Xray自带的DNS模块替代原DNS进行解析，解决以上问题。

## 鸣谢

- [Project X](https://github.com/XTLS/Xray-core)
- [Caddy 2](https://github.com/caddyserver/caddy)
