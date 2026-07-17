#!/bin/bash
# ============================================================
# 一次性脚本：将所有历史任务文档转为 Markdown 并推送 GitHub
# ============================================================
set -e
shopt -s nullglob

SYNC_DIR="/home/ubuntu/obsidian-sync"
HERMES="/home/ubuntu/.hermes"
COUNT=0

echo "📦 历史文件批量同步"
echo "===================="

# 数学知识点
for f in $HERMES/daily-math-knowledge/output/*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/01-数学知识点/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 数学知识点: $(ls $SYNC_DIR/01-数学知识点/*.md 2>/dev/null | wc -l) 篇"

# 成都好文
for f in $HERMES/daily-chengdu-literature/output/*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/02-成都好文/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 成都好文: $(ls $SYNC_DIR/02-成都好文/*.md 2>/dev/null | wc -l) 篇"

# 英语词汇
for f in $HERMES/daily-essay-output/*英语词汇*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/03-英语词汇/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 英语词汇: $(ls $SYNC_DIR/03-英语词汇/*.md 2>/dev/null | wc -l) 篇"

# 物理
for f in $HERMES/daily-physics-knowledge/output/*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/04-物理知识点/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 物理知识点: $(ls $SYNC_DIR/04-物理知识点/*.md 2>/dev/null | wc -l) 篇"

# 美股A股 Excel
for f in $HERMES/daily-finance-output/*美股Top10*.xlsx; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    date_str=$(echo "$base" | grep -oP '\d{8}')
    cp "$f" "$SYNC_DIR/05-美股A股报告/$base"
    cat > "$SYNC_DIR/05-美股A股报告/${date_str}_美股A股报告.md" << MDEOF
---
date: ${date_str}
type: 投资报告
tags: [美股, A股]
---

# 📊 美股 Top10 × A股 合作伙伴报告

📎 [${base}](${base})
MDEOF
    ((COUNT++))
done
echo "✅ 美股A股报告: $(ls $SYNC_DIR/05-美股A股报告/*.xlsx 2>/dev/null | wc -l) 份"

# 投资理财早报
for f in $HERMES/daily-finance-output/*投资理财早报*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/06-投资理财早报/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 投资早报: $(ls $SYNC_DIR/06-投资理财早报/*.md 2>/dev/null | wc -l) 篇"

# AI早报
for f in $HERMES/daily-ai-news/output/*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/07-AI早报/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ AI早报: $(ls $SYNC_DIR/07-AI早报/*.md 2>/dev/null | wc -l) 篇"

# 作文素材
for f in $HERMES/daily-essay-output/*作文素材*.docx; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .docx)
    pandoc "$f" -t markdown -o "$SYNC_DIR/09-作文素材/${base}.md" --wrap=none 2>/dev/null && ((COUNT++))
done
echo "✅ 作文素材: $(ls $SYNC_DIR/09-作文素材/*.md 2>/dev/null | wc -l) 篇"

echo ""
echo "📊 共转换 $COUNT 个文件"

# Git 提交推送
cd "$SYNC_DIR"
git add -A .
git commit -m "📚 历史全部任务文档批量同步 ($(date +%Y-%m-%d))" || echo "(无变更)"
git push origin main 2>&1

echo "✅ 全部完成！"
