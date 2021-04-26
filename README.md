# NFddns

## 写在前面

为了方便使用，定制 ddns 镜像以支持环境变量启动

## 镜像说明

基于 [newfuture/ddns:v2.9.10](https://hub.docker.com/layers/newfuture/ddns/v2.9.10/images/sha256-76acf98eb2a256db17884e3b7a738d7dfa1901576a3d0018c38d60e7fa658a66) 镜像，使用 shell 脚本支持从环境变量获取参数并启动：

* 获取环境变量并渲染出 ddns 配置文件 `config.json`
* 获取环境变量并渲染出 ddns 定制任务 '/etc/crontabs/root'

实现利用环境变量、免挂载配置文件启动，对使用 docker 更加友好 

## 环境变量


| 变量名 | 变量说明 | 对应参数 |
|---|---|---|
| NFD_ID | api 访问 ID | `id` |
| NFD_TOKEN | api 授权 token | `token` |
| NFD_DNS | dns 服务商 | `dns` |
| NFD_IPV4 | ipv4 域名列表 | `ipv4` |
| NFD_IPV6 | ipv6 域名列表 | `ipv6` |
| NFD_INDEX4 | ipv4 获取方式 | `index4` |
| NFD_INDEX6 | ipv6 获取方式 | `index6` |
| NFD_TTL | DNS 解析 TTL 时间 | `ttl` |
| NFD_PROXY | http 代理`;`分割 | `proxy` |
| NFD_DEBUG | 是否开启调试 | `debug` |
| NFD_CACHE | 是否缓存记录 | `cache` |
| NFD_INTERVALS | 定时任务间隔，默认 5min | 无 | 

相关环境变量对应配置基本于官方配置项一致，详见：[NewFuture/DDNS#配置参数表](https://github.com/NewFuture/DDNS#%E9%85%8D%E7%BD%AE%E5%8F%82%E6%95%B0%E8%A1%A8)

部分参数存在差异：

* `VALID_IP_METHOD`，只支持了以下几种获取 IP 的方法（也就不在下方则不支持）：
  * 字符串 `"default"`: 系统访问外网默认 IP
  * 字符串 `"public"`: 使用公网 ip (使用公网 API 查询,url 的简化模式)
  * 字符串 `"interface"`: 使用指定网卡 ip (如: `"interface:eno1"`)
  * 字符串 `"url:xxx"`: 打开 URL xxx (如: `"url:http://ip.sb"`),从返回的数据提取 IP 地址

* `NFD_INTERVALS`，该参数并非 ddns 本身的参数，而是用于设置定时任务，仅支持设置 1-60 的间隔时间

配置模板：

```
{
    "id": $NFD_ID,
    "token": $NFD_TOKEN,
    "dns": $NFD_DNS,
    "index4": $NFD_INDEX4,
    "index6": $NFD_INDEX6,
    "ipv4": $NFD_IPV4,
    "ipv6": $NFD_IPV6,
    "proxy": $NFD_PROXY,
    "ttl": $NFD_TTL,
    "debug": $NFD_DEBUG,
    "$schema": "https://ddns.newfuture.cc/schema/v2.8.json"
}
```


## 如何使用

* 如果你是在 unraid 上使用，建议配置我提供的模板仓库，可以实现快速配置部署：https://github.com/shuosiw/unraid
* 如果你是常规 docker 部署，可以在启动镜像的时候设置环境变量进行配置，比如：

  ```
  docker run -e NFD_ID='test_id' -e NFD_TOKEN='test_token' \
      -e NFD_DNS='dnspod' -e NFD_IPV4='ddns.xxx.com,ipv4.ddns.xxx.com' \
      -e NFD_IPV6='ddns.xxx.com,ipv6.ddns.xxx.com' -e NFD_INDEX4='default' \
      -e NFD_INDEX6='public' -e NFD_TTL='600' -e NFD_PROXY='' \
      -e NFD_DEBUG='' -e NFD_CACHE='' --name nfddns -d  nfddns:test
  ```

## 感谢

* [NewFuture/DDNS](https://github.com/NewFuture/DDNS)