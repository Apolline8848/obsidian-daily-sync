#!/usr/bin/env python3
"""一次性批量转换所有历史文档并推送到 GitHub"""
import subprocess, os, glob, shutil

SYNC = "/home/ubuntu/obsidian-sync"
HERMES = "/home/ubuntu/.hermes"
total = 0

def convert_docx(src_pattern, dst_dir):
    """将匹配的 docx 批量转为 md"""
    global total
    os.makedirs(dst_dir, exist_ok=True)
    files = sorted(glob.glob(src_pattern))
    for f in files:
        base = os.path.splitext(os.path.basename(f))[0]
        dst = os.path.join(dst_dir, f"{base}.md")
        if os.path.exists(dst):
            continue  # 跳过已存在的
        try:
            subprocess.run(["pandoc", f, "-t", "markdown", "-o", dst, "--wrap=none"],
                          check=True, capture_output=True, timeout=30)
            total += 1
        except Exception as e:
            print(f"  ⚠️ 转换失败: {os.path.basename(f)} - {e}")
    return len(files)

def copy_xlsx(src_pattern, dst_dir):
    """复制 xlsx 并生成索引 md"""
    global total
    os.makedirs(dst_dir, exist_ok=True)
    files = sorted(glob.glob(src_pattern))
    for f in files:
        base = os.path.basename(f)
        date_str = base[:8] if len(base) >= 8 else "unknown"
        xlsx_dst = os.path.join(dst_dir, base)
        md_dst = os.path.join(dst_dir, f"{date_str}_美股A股报告.md")
        if not os.path.exists(xlsx_dst):
            shutil.copy2(f, xlsx_dst)
        if not os.path.exists(md_dst):
            with open(md_dst, "w", encoding="utf-8") as fh:
                fh.write(f"---\ndate: {date_str}\ntype: 投资报告\ntags: [美股, A股]\n---\n\n")
                fh.write(f"# 📊 美股 Top10 × A股 合作伙伴报告\n\n📎 [{base}]({base})\n")
        total += 1
    return len(files)

print("📦 历史文件批量同步")
print("=" * 20)

tasks = [
    ("数学知识点", f"{HERMES}/daily-math-knowledge/output/*.docx",
     f"{SYNC}/01-数学知识点", "docx"),
    ("成都好文", f"{HERMES}/daily-chengdu-literature/output/*.docx",
     f"{SYNC}/02-成都好文", "docx"),
    ("英语词汇", f"{HERMES}/daily-essay-output/*英语词汇*.docx",
     f"{SYNC}/03-英语词汇", "docx"),
    ("物理知识点", f"{HERMES}/daily-physics-knowledge/output/*.docx",
     f"{SYNC}/04-物理知识点", "docx"),
    ("美股A股报告", f"{HERMES}/daily-finance-output/*美股Top10*.xlsx",
     f"{SYNC}/05-美股A股报告", "xlsx"),
    ("投资早报", f"{HERMES}/daily-finance-output/*投资理财早报*.docx",
     f"{SYNC}/06-投资理财早报", "docx"),
    ("AI早报", f"{HERMES}/daily-ai-news/output/*.docx",
     f"{SYNC}/07-AI早报", "docx"),
    ("作文素材", f"{HERMES}/daily-essay-output/*作文素材*.docx",
     f"{SYNC}/09-作文素材", "docx"),
]

results = []
for name, pattern, dst_dir, ftype in tasks:
    if ftype == "docx":
        cnt = convert_docx(pattern, dst_dir)
    else:
        cnt = copy_xlsx(pattern, dst_dir)
    results.append((name, cnt))
    print(f"  {name}: {cnt} 个文件")

print(f"\n📊 共转换 {total} 个文件")

# Git 操作
print("\n📦 Git 提交 & 推送...")
os.chdir(SYNC)
subprocess.run(["git", "add", "-A"], check=True)
result = subprocess.run(["git", "commit", "-m", f"📚 历史全部任务文档批量同步 ({len(glob.glob(SYNC+'/*/*.md'))}篇)"],
                       capture_output=True, text=True)
if "nothing to commit" in result.stdout + result.stderr:
    print("  (无新变更)")
else:
    print(f"  {result.stdout.strip()}")
subprocess.run(["git", "push", "origin", "main"], check=True, timeout=60)
print("✅ 全部完成！")
