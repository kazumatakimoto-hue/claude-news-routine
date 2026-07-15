#!/usr/bin/env bash
# SessionStart hook: MaaS・駐車場ニュース収集ルーチン用の日付ガードレール。
# 実行日(今日)と対象日(前日)を JST で機械的に算出し、コンテキストへ注入する。
# 目的: エージェントが今日/前日を自分で推測・暗算して取り違える事故を防ぐ。
set -euo pipefail

TZ_JST="Asia/Tokyo"

# JST の現在日時（実行日 = 今日）
TODAY=$(TZ="$TZ_JST" date '+%Y-%m-%d')
TODAY_DOW=$(TZ="$TZ_JST" date '+%a')
NOW=$(TZ="$TZ_JST" date '+%Y-%m-%d %H:%M %Z')

# 対象日 = 前日 = 今日 - 1日（月またぎ・年またぎは date が自動処理）
YDAY=$(TZ="$TZ_JST" date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null \
  || TZ="$TZ_JST" date -v-1d '+%Y-%m-%d')   # GNU date / BSD date 両対応
YDAY_DOW=$(TZ="$TZ_JST" date -d "$YDAY" '+%a' 2>/dev/null \
  || TZ="$TZ_JST" date -v-1d '+%a')

cat <<EOF
=== 📅 日付ガードレール（JST / Asia/Tokyo・機械算出値・必読）===
現在(JST): ${NOW}
実行日 (今日):        ${TODAY} (${TODAY_DOW})
対象日 (前日=収集対象): ${YDAY} (${YDAY_DOW})

⚠️ 上の「対象日」は date コマンドで確定した正値です。
   ニュース収集の対象期間は必ず「対象日 ${YDAY} の 00:00〜23:59 (JST)」のみ。
   今日/前日を自分で暗算・推測して別の日付を使わないこと。
   Notion 保存時の「対象日（前日分）」も ${YDAY} を用いること。
================================================================
EOF
