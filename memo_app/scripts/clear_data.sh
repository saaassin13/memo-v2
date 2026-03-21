#!/bin/bash
# 清空 Memo App 测试数据
# 用法: bash scripts/clear_data.sh [linux|android|all]

set -e

PLATFORM="${1:-linux}"
PACKAGE="com.memo.memo_app"
DB_NAME="memo_app.db"

clear_linux() {
  # 搜索所有可能的 Linux 数据目录
  XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
  FOUND=0

  for dir in "$XDG/$PACKAGE" "$XDG/com.example.memo_app" "$XDG/memo_app"; do
    DB_FILE="$dir/$DB_NAME"
    if [ -f "$DB_FILE" ]; then
      rm -f "$DB_FILE" "$DB_FILE-journal" "$DB_FILE-wal" "$DB_FILE-shm"
      echo "已删除: $DB_FILE"
      FOUND=1
    fi
  done

  # 也尝试直接搜索
  if [ "$FOUND" -eq 0 ]; then
    RESULT=$(find "$XDG" -name "$DB_NAME" -type f 2>/dev/null | head -5)
    if [ -n "$RESULT" ]; then
      while IFS= read -r f; do
        rm -f "$f" "$f-journal" "$f-wal" "$f-shm"
        echo "已删除: $f"
        FOUND=1
      done <<< "$RESULT"
    fi
  fi

  if [ "$FOUND" -eq 0 ]; then
    echo "未找到 Linux 数据库文件 ($DB_NAME)"
  fi
}

clear_android() {
  if ! command -v adb &> /dev/null; then
    echo "错误: adb 未找到，请安装 Android SDK"
    exit 1
  fi

  DEVICE=$(adb devices | grep -v "List" | grep "device$" | head -1 | cut -f1)
  if [ -z "$DEVICE" ]; then
    echo "错误: 未检测到已连接的 Android 设备"
    exit 1
  fi

  adb shell pm clear "$PACKAGE"
  echo "已清空 Android 应用数据 ($PACKAGE)"
}

case "$PLATFORM" in
  linux)
    clear_linux
    ;;
  android)
    clear_android
    ;;
  all)
    clear_linux
    clear_android
    ;;
  *)
    echo "用法: bash scripts/clear_data.sh [linux|android|all]"
    exit 1
    ;;
esac

echo "完成。重启应用以重新创建空数据库。"
