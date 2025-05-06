# Stash Config Center

基于本地规则的 Stash 配置中心，用于管理和自动生成 Stash 配置文件。

## 目录结构

```
.
├── config/                 # 配置模板目录
│   └── Stash-Config.yaml   # Stash 配置模板
├── rules/                  # 本地规则文件目录
│   ├── YouTube.yaml        #
│   ├── Google.yaml         #
│   └── ...                 # 其他规则文件
├── scripts/                # 脚本目录
│   ├── update_rules.sh     # 更新规则脚本
│   └── build_config.sh     # 构建配置脚本
├── public/                 # 公共发布目录
│   └── rules/              # 规则发布目录
│       ├── YouTube.yaml    #
│       ├── Google.yaml     #
│       └── ...             # 其他规则文件
└── private/                # 私有配置目录
    └── config.yaml         # 生成的Stash配置文件
```

## 使用说明

### 更新规则

当您编辑或添加新的规则文件后，运行：

```bash
./scripts/update_rules.sh
```

这将更新`public/rules`目录中的规则文件，并重新生成配置文件。

## Link

1. [ProxySoftware-Template-Config](https://github.com/zuluion/ProxySoftware-Template-Config)
