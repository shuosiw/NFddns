# NFddns

## 写在前面

## 镜像说明


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

配置模板如下：

```
{
  "$schema": "https://ddns.newfuture.cc/schema/v2.8.json",
  "id": "12345",
  "token": "mytokenkey",
  "dns": "dnspod",
  "ipv4": ["ddns.newfuture.cc", "ipv4.ddns.newfuture.cc"],
  "ipv6": ["ddns.newfuture.cc", "ipv6.ddns.newfuture.cc"],
  "index4": 0,
  "index6": "public",
  "ttl": 600,
  "proxy": "127.0.0.1:1080;DIRECT",
  "debug": false,
  "cache": true
}
```


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


jq   NFD_ID "$FILENAME" '{"type":"test","params":{"item":{"file": $v}}}'

## 如何使用

## 感谢

* [NewFuture/DDNS](https://github.com/NewFuture/DDNS)