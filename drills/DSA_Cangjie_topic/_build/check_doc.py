# -*- coding: utf-8 -*-
"""Check that 大纲.md and the shipped 题面.md agree on level names and problem titles.

Build-time QA only. stdout stays ASCII (a cp936 console mangles UTF-8), so the
Chinese details go to _build/check_doc_report.txt, written as UTF-8.

  * level theme: 大纲 heading "### D3 · <theme>" vs 题面 "**关卡**：D3 · <theme>"
  * problem title: 大纲 table row "| `D3-B` | <title> |" vs 题面 first line "# D3-B · <title>"

A title passes when one normalized form is a prefix of the other, so a 题面 that
adds a parenthetical ("0/1 背包（恰好装满）") is not reported as a mismatch.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROB = os.path.join(ROOT, 'problems')
SYL = os.path.join(ROOT, '大纲.md')
REPORT = os.path.join(ROOT, '_build', 'check_doc_report.txt')


def norm(s):
    s = s.replace('★', '').strip()
    s = re.sub(r'^D\d+-[A-Z]\s*·\s*', '', s)
    s = re.sub(r'[（）()［］\[\]、,，:：`*\s]', '', s)
    return s


def main():
    with open(SYL, 'rb') as f:
        syl = f.read().decode('utf-8')

    themes = {}
    for m in re.finditer(r'^###\s+D(\d+)\s*·\s*(.+)$', syl, re.M):
        themes[int(m.group(1))] = m.group(2).strip()

    syl_titles = {}
    for m in re.finditer(r'\|\s*`(D\d+-[A-Z])`\s*\|\s*([^|]+?)\s*\|', syl):
        syl_titles[m.group(1)] = m.group(2).strip()

    problems = []
    if os.path.isdir(PROB):
        problems = sorted(d for d in os.listdir(PROB) if re.match(r'^D\d+-[A-Z]$', d))

    report = []
    bad = 0
    for pid in problems:
        md = os.path.join(PROB, pid, '题面.md')
        if not os.path.isfile(md):
            report.append('MISSING %s 题面.md' % pid)
            print('MISSING  %s' % pid)
            bad += 1
            continue
        with open(md, 'rb') as f:
            raw = f.read()
        if raw.startswith(b'\xef\xbb\xbf'):
            raw = raw[3:]
        text = raw.decode('utf-8')

        first = re.search(r'^#\s+(.+)$', text, re.M)
        st_title = first.group(1).strip() if first else ''
        lv = re.search(r'\*\*关卡\*\*[：: ]*(.+)', text)
        st_level = lv.group(1).strip() if lv else ''

        n = int(pid.split('-')[0][1:])
        want_theme = themes.get(n, '')
        got_theme = st_level.split('·', 1)[1].split('｜')[0].strip() if '·' in st_level else st_level
        if want_theme and norm(want_theme) != norm(got_theme):
            report.append('THEME %s  syllabus=[%s]  statement=[%s]' % (pid, want_theme, got_theme))
            print('THEME    %s' % pid)
            bad += 1

        want_title = syl_titles.get(pid, '')
        if want_title:
            a, b = norm(want_title), norm(st_title)
            if not (a == b or b.startswith(a) or a.startswith(b)):
                report.append('TITLE %s  syllabus=[%s]  statement=[%s]' % (pid, want_title, st_title))
                print('TITLE    %s' % pid)
                bad += 1

    with open(REPORT, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(report) + ('\n' if report else ''))
    print('\n%d problems, %d mismatch(es)' % (len(problems), bad))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
