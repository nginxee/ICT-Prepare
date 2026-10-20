#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Generate problems/INDEX.md from the 题面.md files.

Usage (from the DSA_Cangjie_topic root, after problems are written):
    python _build\\make_index.py

It reads each problems\\D<n>-<X>\\题面.md and pulls out:
  * the title line  "# D3-B · 后缀表达式求值"
  * the 关卡 line   "**关卡**：D3 · 栈"
  * the bullet list under "## 知识点"
  * case count from the in/ directory
Then emits the level table (18 rows) and the per-problem tables.

The header prose is generated from 大纲.md's level names, so INDEX.md can never
drift from the syllabus: both come from the same source of truth.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROB = os.path.join(ROOT, 'problems')
OUT = os.path.join(PROB, 'INDEX.md')


def parse_statement(path):
    with open(path, 'rb') as f:
        raw = f.read()
    if raw.startswith(b'\xef\xbb\xbf'):
        raw = raw[3:]
    md = raw.decode('utf-8')

    title = ''
    m = re.search(r'^#\s+(.+)$', md, re.M)
    if m:
        title = m.group(1).strip()

    level_line = ''
    m = re.search(r'\*\*关卡\*\*[：: ]*(.+)', md)
    if m:
        level_line = m.group(1).strip()

    points = []
    m = re.search(r'##\s*知识点\s*\n(.*?)(?:\n##\s|\Z)', md, re.S)
    if m:
        for ln in m.group(1).split('\n'):
            ln = ln.strip()
            if ln.startswith('- '):
                points.append(ln[2:].strip())
    return title, level_line, points


def short_points(points, limit=3):
    """Keep the table cell readable: first `limit` points, joined by ' / '."""
    pts = [re.sub(r'`([^`]*)`', r'\1', p) for p in points[:limit]]
    return ' / '.join(pts)


def main():
    if not os.path.isdir(PROB):
        print('no problems dir: %s' % PROB)
        return 2

    # D<level>-<letter> -> info
    probs = {}
    levels = {}
    for d in sorted(os.listdir(PROB)):
        pdir = os.path.join(PROB, d)
        if not os.path.isdir(pdir):
            continue
        m = re.match(r'^D(\d+)-([A-Z])$', d)
        if not m:
            continue
        lv, letter = int(m.group(1)), m.group(2)
        md = os.path.join(pdir, '题面.md')
        if not os.path.isfile(md):
            print('skip %s (no 题面.md)' % d)
            continue
        title, level_line, points = parse_statement(md)
        # "D3 · 栈" -> theme "栈"
        theme = ''
        if '·' in level_line:
            theme = level_line.split('·', 1)[1].split('｜')[0].strip()
        cases = 0
        ind = os.path.join(pdir, 'in')
        if os.path.isdir(ind):
            cases = len([x for x in os.listdir(ind) if x.endswith('.txt')])
        stars = '★' if letter == 'D' else ''
        probs[d] = dict(id=d, level=lv, letter=letter, title=title, theme=theme,
                        points=points, cases=cases, star=stars)
        levels.setdefault(lv, theme)

    if not probs:
        print('no problems found')
        return 2

    total = len(probs)
    lines = []
    lines.append('# 题目索引')
    lines.append('')
    lines.append('> 共 **%d 关 / %d 题**（生成自各题 `题面.md`，别手改本文件：改完题面跑 `python _build\\make_index.py`）。'
                 % (len(levels), total))
    lines.append('> 判题：双击 `..\\自助判题.cmd`，输入关卡号（如 `8`）或题号（如 `D8-C`）；命令行见 `..\\使用说明.md`。')
    lines.append('> 关卡的知识点、复杂度目标与学习路线见 `..\\大纲.md`。')
    lines.append('')
    lines.append('## 关卡总表')
    lines.append('')
    lines.append('| 关卡 | 主题 | 题数 | ★ |')
    lines.append('|---|---|---|---|')
    for lv in sorted(levels):
        n = sum(1 for p in probs.values() if p['level'] == lv)
        s = sum(1 for p in probs.values() if p['level'] == lv and p['star'])
        lines.append('| D%d | %s | %d | %d |' % (lv, levels[lv], n, s))
    lines.append('')
    lines.append('## 逐题表')
    lines.append('')
    for lv in sorted(levels):
        lines.append('### D%d · %s' % (lv, levels[lv]))
        lines.append('')
        lines.append('> 知识点与建议：`..\\notes\\D%02d.md`' % lv)
        lines.append('')
        lines.append('| 题号 | 标题 | 用例 |')
        lines.append('|---|---|---|')
        for d in sorted((p for p in probs.values() if p['level'] == lv),
                        key=lambda x: x['letter']):
            # title already starts with "D3-B · "; strip the id prefix for the cell
            t = d['title']
            t = re.sub(r'^D\d+-[A-Z]\s*·\s*', '', t)
            lines.append('| `%s` | %s%s | %d |'
                         % (d['id'], d['star'], t if not d['star'] else ' ' + t,
                            d['cases']))
        lines.append('')

    text = '\n'.join(lines).rstrip() + '\n'
    with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    print('wrote %s  (%d levels, %d problems)' % (OUT, len(levels), total))
    return 0


if __name__ == '__main__':
    sys.exit(main())
