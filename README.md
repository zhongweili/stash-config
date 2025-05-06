# Stash Config Center

基于本地规则的 Stash 配置中心，用于管理和自动生成 Stash 配置文件。

## 功能特点

- 基于本地规则文件，无需依赖外部仓库
- 自动检测和集成所有规则文件
- 保持 CDN 链接不变
- 简化配置文件生成和更新流程
- 支持通过 GitHub Actions 自动发布
- 配置文件保存在私有目录，规则文件公开分享

## 目录结构

```
.
├── config/                 # 配置模板目录
│   └── Stash-Config.yaml   # Stash 配置模板
├── rules/                  # 本地规则文件目录
│   ├── YouTube.yaml        # YouTube规则
│   ├── Google.yaml         # Google规则
│   └── ...                 # 其他规则文件
├── scripts/                # 脚本目录
│   ├── initialize.sh       # 初始化脚本
│   ├── update_rules.sh     # 更新规则脚本
│   └── build_config.sh     # 构建配置脚本
├── public/                 # 公共发布目录
│   └── rules/              # 规则发布目录
│       ├── YouTube.yaml    # YouTube规则（公开）
│       ├── Google.yaml     # Google规则（公开）
│       └── ...             # 其他规则文件
└── private/                # 私有配置目录
    └── config.yaml         # 生成的Stash配置文件
```

## 使用说明

### 初始化

首次使用时，运行初始化脚本：

```bash
./scripts/initialize.sh
```

这将创建必要的目录、复制规则文件到`public/rules`目录，并生成 Stash 配置文件到`private/config.yaml`。

### 更新规则

当您编辑或添加新的规则文件后，运行：

```bash
./scripts/update_rules.sh
```

这将更新`public/rules`目录中的规则文件，并重新生成配置文件。

## 规则编写指南

规则文件应放在`rules/`目录下，使用 YAML 格式：

```yaml
payload:
  - DOMAIN-SUFFIX,example.com
  - DOMAIN-KEYWORD,example
  - IP-CIDR,192.168.1.0/24
```

## CDN 发布

将`public/rules`目录的内容推送到 GitHub 仓库后，您可以通过 jsDelivr CDN 访问规则文件：

```
https://cdn.jsdelivr.net/gh/zhongwei/stash_config@master/rules/<规则名>.yaml
```

### 与 GitHub Actions 集成

您可以创建 GitHub Actions 工作流程，在每次推送到仓库时自动更新规则：

```yaml
name: Update Stash Rules

on:
  push:
    branches: [main]
    paths:
      - "rules/**"

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Update Rules
        run: |
          ./scripts/update_rules.sh
      - name: Commit and Push
        run: |
          git config --global user.name 'GitHub Action'
          git config --global user.email 'action@github.com'
          git add public/rules/
          git commit -m "Update rules" || exit 0
          git push
```

## 安全说明

- 配置文件保存在`private/config.yaml`，不会发布到公共 CDN
- 只有规则文件会发布到公共 CDN，供其他用户使用
- 确保您的私有配置不会被意外上传到公共仓库

## 问题与帮助

如有任何问题，请提交 Issue 或 PR。

# Clash-Template-Config

> 自用 Clash 配置文件模板

[Clash Template Config](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Clash-Template-Config.yml)

> 因为 CFA 已经很久没有更新，最新的配置文件模板基于使用了新的 proxy-group filter 特性，因此无法在 CFA 中使用，建议使用 0.0.11 版本，为此特地创建新的用于 CFA 的临时配置文件

[Clash Template Config Temp For CFA](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Clash-Template-Config_temp-for-cfa.yml)

# App Filter

> 应用分流规则

- [AdBlock](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/AdBlock.yaml)
- [Adobe](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Adobe.yaml)
- [Amazon](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Amazon.yaml)
- [Apple](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Apple.yaml)
- [BiliBili](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Bilibili.yaml)
- [China](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/China.yaml)
- [Claude](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Claude.yaml)
- [Copilot](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Copilot.yaml)
- [DownLoadClient](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/DownLoadClient.yaml)
- [Direct](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Direct.yaml)
- [Discord](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Discord.yaml)
- [DisneyPlus](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/DisneyPlus.yaml)
- [Facebook](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Facebook.yaml)
- [Gemini](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Gemini.yaml)
- [GitHub](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/GitHub.yaml)
- [Google](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Google.yaml)
- [HBO](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/HBO.yaml)
- [Hulu](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Hulu.yaml)
- [IDM](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/IDM.yaml)
- [Netflix](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Netflix.yaml)
- [Netch](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Netch.yaml)
- [OneDrive](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/OneDrive.yaml)
- [OutLook](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/OutLook.yaml)
- [OpenAI](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/OpenAI.yaml)
- [JavSP](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/JavSP.yaml)
- [Microsoft](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Microsoft.yaml)
- [PayPal](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/PayPal.yaml)
- [Perplexity](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Perplexity.yaml)
- [Proxy](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Proxy.yaml)
- [ProxyClient](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/ProxyClient.yaml)
- [PikPak](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/PikPak.yaml)
- [Reddit](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Reddit.yaml)
- [Spotify](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Spotify.yaml)
- [Speedtest](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Speedtest.yaml)
- [Steam](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Steam.yaml)
- [Ubisoft](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Ubisoft.yaml)
- [Telegram](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Telegram.yaml)
- [Twitter](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Twitter.yaml)
- [Tencent](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/Tencent.yaml)
- [TikTok](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/TikTok.yaml)
- [YouTube](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Filter/YouTube.yaml)

> PS:
>
> 1. Hulu 和 HBO 包含了不同地区的域名规则，建议实际应用中拆分开，因暂无这两个流媒体的实际应用需求，故未将其分开
> 2. IDM 并不支持 BT 和磁力链接，因此单独区分开，并设置相应的策略组，默认走直连，也可以前端手动改成走国内流量
> 3. 添加锚点，提高复用率，降低单次修改的成本 2022-09-20 修改
> 4. 现在可以通过 powershell 执行 `powershell -nop -c "iex(iwr 'https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Script/ini-clash-provider.ps1')"` 来完成 `provider` 的初始化和调用 clash 安装模板文件，也可以下载 `ini-clash-provider.exe` 到本地执行
> 5. Android 建议复制 [Clash Template Config](https://cdn.jsdelivr.net/gh/zuluion/Clash-Template-Config@master/Clash-Template-Config.yml) 的代码，并填写自己的机场订阅，以此创建自己的 Gist 使用，实际上其它客户端也可以类似操作，从而跳过初始化的过程，此前的初始化是用于 CFW，并使用 Diff 来合并自己机场订阅用的
> 6. 新增了 WARP 配置，默认禁用，需要自写 WARP 节点配置，模板在https://github.com/zuluion/Clash-Template-Config/blob/master/Ini-Files/provider-warp.yml
> 7. 新增加了 proxychain(relay)配置，可以用未被墙的节点，拯救被墙的节点
> 8. 新增了 DNS 配置，降低 DNS 污染几率
> 9. 新增了 localproxy 配置，用于配置局域网的 socks 代理，勉强实现不同网络环境下的自动切换，默认禁用

## Link

1. [ProxySoftware-Template-Config](https://github.com/zuluion/ProxySoftware-Template-Config)

## Star history

<a href="https://star-history.com/#zuluion/Clash-Template-Config&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=zuluion/Clash-Template-Config&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=zuluion/Clash-Template-Config&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=zuluion/Clash-Template-Config&type=Date" width="100%" />
 </picture>
</a>

## Contributors

<a href="https://github.com/zuluion/ProxySoftware-Template-Config/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=zuluion/Clash-Template-Config" width="100"/>
</a>

## CDN 链接

通过 jsDelivr CDN 分发的文件：

- [Stash 配置文件](https://cdn.jsdelivr.net/gh/zhongwei/stash_config@master/public/stash-config.yaml)
- [规则目录](https://cdn.jsdelivr.net/gh/zhongwei/stash_config@master/public/rules/)

## 使用方法

1. 在 Stash 中添加订阅，URL 为上述 Stash 配置文件的 CDN 链接
2. 更新配置和发布规则：
   ```bash
   # 将本地 rules/ 目录的规则处理并发布到 public/ 目录
   # 同时根据你的设置生成 Stash 配置文件
   ./scripts/initialize.sh
   ```
3. 推送到 GitHub 后，等待 jsDelivr 缓存刷新（通常几分钟内）

## 配置文件说明

- 基于 Clash 配置，专为 Stash 优化
- 内置丰富的应用分流规则
- 支持自定义节点筛选、策略组
- 机场订阅：在 `scripts/initialize.sh` 中通过 `-a` 选项设置
