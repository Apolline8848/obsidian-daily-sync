#!/bin/bash
# ============================================================
# 每日任务 → Obsidian 同步脚本
# 将各任务生成的 docx/xlsx 转为 Markdown，提交到 Git 仓库
# 建议每天 19:30 执行（所有任务完成后）
# ============================================================
set -e

SYNC_DIR="/home/ubuntu/obsidian-sync"
HERMES_DIR="/home/ubuntu/.hermes"
TODAY=$(date +%Y%m%d)
TODAY_CN=$(date +%Y年%m月%d日)

echo "🔄 Obsidian 同步开始 — $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ---------- 1. 数学知识点 ----------
SRC="$HERMES_DIR/daily-math-knowledge/output/${TODAY}_每日数学知识点.docx"
DST_DIR="$SYNC_DIR/01-数学知识点"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_每日数学知识点.md" --wrap=none 2>/dev/null
    echo "✅ 数学知识点"
else
    echo "⚠️  数学知识点 — 文件不存在，跳过"
fi

# ---------- 2. 成都好文 ----------
SRC="$HERMES_DIR/daily-chengdu-literature/output/每日成都好文鉴赏_${TODAY}.docx"
DST_DIR="$SYNC_DIR/02-成都好文"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_每日成都好文鉴赏.md" --wrap=none 2>/dev/null
    echo "✅ 成都好文"
else
    echo "⚠️  成都好文 — 文件不存在，跳过"
fi

# ---------- 3. 英语词汇 ----------
SRC="$HERMES_DIR/daily-essay-output/${TODAY}_英语词汇故事.docx"
DST_DIR="$SYNC_DIR/03-英语词汇"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_英语词汇故事.md" --wrap=none 2>/dev/null
    echo "✅ 英语词汇"
else
    echo "⚠️  英语词汇 — 文件不存在，跳过"
fi

# ---------- 4. 物理知识点 ----------
SRC="$HERMES_DIR/daily-physics-knowledge/output/${TODAY}_每日物理知识点.docx"
DST_DIR="$SYNC_DIR/04-物理知识点"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_每日物理知识点.md" --wrap=none 2>/dev/null
    echo "✅ 物理知识点"
else
    echo "⚠️  物理知识点 — 文件不存在，跳过（可能已暂停）"
fi

# ---------- 5. 美股A股报告 (xlsx → 保留原文件 + 简单说明) ----------
SRC="$HERMES_DIR/daily-finance-output/${TODAY}_美股Top10_11Sheet.xlsx"
DST_DIR="$SYNC_DIR/05-美股A股报告"
if [ -f "$SRC" ]; then
    # Excel 不适合转 markdown，复制原文件 + 生成索引 md
    cp "$SRC" "$DST_DIR/${TODAY}_美股Top10_11Sheet.xlsx"
    cat > "$DST_DIR/${TODAY}_美股A股报告.md" << EOF
---
date: ${TODAY_CN}
type: 投资报告
tags: [美股, A股, 投资]
---

# 📊 美股 Top10 × A股 合作伙伴报告

> 生成日期：${TODAY_CN}

📎 附件：[${TODAY}_美股Top10_11Sheet.xlsx](${TODAY}_美股Top10_11Sheet.xlsx)

> ⚠️ 此报告为 11 Sheet Excel 文件，含美股涨幅前10及对应A股合作企业完整财务数据，请在 Obsidian 中点击附件查看。
EOF
    echo "✅ 美股A股报告"
else
    echo "⚠️  美股A股报告 — 文件不存在，跳过"
fi

# ---------- 6. 投资理财早报 ----------
SRC="$HERMES_DIR/daily-finance-output/${TODAY}_全球投资理财早报.docx"
DST_DIR="$SYNC_DIR/06-投资理财早报"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_全球投资理财早报.md" --wrap=none 2>/dev/null
    echo "✅ 投资理财早报"
else
    echo "⚠️  投资理财早报 — 文件不存在，跳过"
fi

# ---------- 7. AI早报 ----------
SRC="$HERMES_DIR/daily-ai-news/output/${TODAY}_全球AI早报.docx"
DST_DIR="$SYNC_DIR/07-AI早报"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_全球AI早报.md" --wrap=none 2>/dev/null
    echo "✅ AI早报"
else
    echo "⚠️  AI早报 — 文件不存在，跳过"
fi

# ---------- 9. 作文素材 ----------
SRC="$HERMES_DIR/daily-essay-output/每日初中作文素材_$(date +%Y-%m-%d).docx"
DST_DIR="$SYNC_DIR/09-作文素材"
if [ -f "$SRC" ]; then
    pandoc "$SRC" -t markdown -o "$DST_DIR/${TODAY}_每日初中作文素材.md" --wrap=none 2>/dev/null
    echo "✅ 作文素材"
else
    echo "⚠️  作文素材 — 文件不存在，跳过"
fi

# ---------- Git 提交 ----------
echo ""
echo "📦 Git 提交 & 推送..."
cd "$SYNC_DIR"
git add -A .
git commit -m "📥 ${TODAY_CN} 每日任务同步" || echo "   (无变更，跳过 commit)"
git push origin main 2>&1 || echo "⚠️  Git push 失败，请检查远程仓库配置"

echo ""
echo "✅ 同步完成 — $(date '+%Y-%m-%d %H:%M:%S')"
