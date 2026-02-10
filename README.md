
# NanoBot-Termux 一键安装脚本

本项目提供一个 **Termux（Android）专用**的一键安装脚本，用于安装 NanoBot 及其常见依赖（含 Rust/C 扩展编译环境），并自动处理 Termux 环境下常见问题（如 `ANDROID_API_LEVEL`、`Text file busy` 等）。

---

## 1. 适用环境

* ✅ Android + Termux
* ✅ Python（Termux 自带包安装）
* ⚠️ 需要网络连接、足够存储空间（编译 Rust 依赖会占用较多空间）

---

## 2. 一键在线安装（推荐）

任选一个命令执行：

### 2.1 curl 方式

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ajwyunsx/NanoBot-Termux/refs/heads/main/i.sh)"
```

### 2.2 wget 方式

```sh
bash -c "$(wget -qO- https://raw.githubusercontent.com/Ajwyunsx/NanoBot-Termux/refs/heads/main/i.sh)"
```

### 2.3 更稳：先下载再运行（便于排查）

```sh
curl -fsSL https://raw.githubusercontent.com/Ajwyunsx/NanoBot-Termux/refs/heads/main/i.sh -o i.sh
chmod +x i.sh
./i.sh
```

---

## 3. 脚本内容（完整步骤说明）

脚本使用 `set -euo pipefail`：

* 任意一步出错会立刻停止，避免“半安装”导致环境更乱。

脚本共 9 步：

### [1/9] 更新 Termux 软件源与包

```sh
pkg update -y
pkg upgrade -y
```

### [2/9] 安装基础编译工具 + Python

```sh
pkg install -y python clang make pkg-config git
```

### [3/9] 安装 lxml 编译所需系统依赖（libxml2/libxslt）

```sh
pkg install -y libxml2 libxslt
```

### [4/9] 安装 Rust 工具链（maturin/pyo3 编译需要）

```sh
pkg install -y rust
```

### [5/9] 修复 Termux 常见编译问题：临时目录 + 并发

用于解决 `Text file busy (os error 26)` 等错误：

```sh
mkdir -p "$HOME/tmp"
export TMPDIR="$HOME/tmp"
export CARGO_BUILD_JOBS=1
```

并自动设置 Android API Level（解决 maturin 报错）：

```sh
ANDROID_API_LEVEL_DETECTED="$(getprop ro.build.version.sdk 2>/dev/null || true)"
export ANDROID_API_LEVEL=...
```

若检测失败，默认使用 `33`。

### [6/9] 升级 pip 与构建工具

```sh
python -m pip install -U pip setuptools wheel
```

### [7/9] 安装 lxml

```sh
python -m pip install -U lxml
```

### [8/9] 安装 Rust 相关 Python 依赖

依次安装：

* `tokenizers`
* `fastuuid`
* `hf-xet`

```sh
python -m pip install -U tokenizers
python -m pip install -U fastuuid
python -m pip install -U hf-xet
```

### [9/9] 安装 NanoBot

```sh
python -m pip install -U nanobot
```

脚本最后会输出当前关键环境变量：

* `TMPDIR`
* `CARGO_BUILD_JOBS`
* `ANDROID_API_LEVEL`

---

## 4. 安装完成后如何使用

安装完成后你可以尝试：

```sh
nanobot --help
```

或（如果项目提供不同命令）：

```sh
python -m nanobot --help
```

> 具体启动命令取决于 nanobot 包本身提供的入口命令。如果提示找不到命令，把输出贴出来即可定位。

---

## 5. 常见问题（FAQ）

### 5.1 maturin 报错：Failed to determine Android API level

脚本已自动设置。若你手动安装遇到，可执行：

```sh
export ANDROID_API_LEVEL=$(getprop ro.build.version.sdk)
```

### 5.2 Rust 编译时报：Text file busy (os error 26)

脚本已处理（TMPDIR + 单线程）。手动修复：

```sh
mkdir -p $HOME/tmp
export TMPDIR=$HOME/tmp
export CARGO_BUILD_JOBS=1
```

### 5.3 lxml 报错缺少 libxml2/libxslt

脚本已安装依赖。手动补依赖：

```sh
pkg install -y libxml2 libxslt clang make pkg-config
pip install -U lxml
```

### 5.4 pip 构建失败/中断怎么办？

由于脚本启用了 `set -e`，遇到错误会中断。你可以：

1. 复制报错最后 30 行
2. 重新执行脚本（脚本是幂等的，多数步骤重复执行无害）

---

## 6. 卸载与清理（可选）

卸载 NanoBot：

```sh
pip uninstall -y nanobot
```

清理 pip 缓存：

```sh
rm -rf ~/.cache/pip
```

清理 Rust 缓存（可选）：

```sh
rm -rf ~/.cargo/registry ~/.cargo/git
```

---

## 7. 安全提示（重要）

在线执行脚本前建议先查看脚本内容：

```sh
curl -fsSL https://raw.githubusercontent.com/Ajwyunsx/NanoBot-Termux/refs/heads/main/i.sh | sed -n '1,200p'
```

确认无误后再执行“一键在线安装”。

---
