#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Problem-bank self-check: mechanically validate 题面 + test data.

Usage (from the DSA_Cangjie_topic root):
    python _build\\check.py            # every problem
    python _build\\check.py D3         # one level
    python _build\\check.py D3-B       # one problem

Output is deliberately ASCII-only, so it reads correctly under a cp936 console.

Checks (any failure => FAIL):
  1. 题面.md exists, UTF-8 without BOM, and has every required section
     (关卡 / 提交文件 / 知识点 / 输入 / 输出 / 样例 / 自测) plus 数据范围
  2. in/ and out/ hold the same file names, >= 4 cases, numbered 01..NN
  3. every .txt is UTF-8 without BOM, LF-only, ends with exactly one newline,
     non-empty, <= 8 MB
  4. each "样例 k" block in 题面.md matches in/0k.txt and out/0k.txt byte for byte
     (after the judge's normalization: trailing spaces and trailing blank lines)
  5. out/ files have no trailing spaces and no stray CR
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROB = os.path.join(ROOT, 'problems')

REQUIRED_SECTIONS = ['**关卡**', '## 输入', '## 输出', '## 样例', '## 自测']
# v2 起：题面只讲任务。知识点/提示一律搬进 notes\D<nn>.md。
FORBIDDEN_SECTIONS = ['## 知识点', '## 提示', '## 技巧', '## 注意']
NOTES_DIR = os.path.join(ROOT, 'notes')
MAX_BYTES = 8 * 1024 * 1024


def read_text(path):
    """Return (text, errors). Requires UTF-8 without BOM."""
    errs = []
    with open(path, 'rb') as f:
        raw = f.read()
    if raw.startswith(b'\xef\xbb\xbf'):
        errs.append('file carries a UTF-8 BOM')
        raw = raw[3:]
    try:
        return raw.decode('utf-8'), errs
    except UnicodeDecodeError as e:
        return None, errs + ['not valid UTF-8: %s' % e]


def norm_lines(text):
    """Normalize the way the judge compares: CRLF->LF, rstrip lines, drop trailing blanks."""
    t = text.replace('\r\n', '\n').replace('\r', '\n')
    lines = [ln.rstrip() for ln in t.split('\n')]
    while lines and lines[-1] == '':
        lines.pop()
    return lines


def parse_samples(md):
    """Extract {k: (input lines, output lines)} from the 题面 sample blocks."""
    samples = {}
    for m in re.finditer(r'\*\*样例\s*(\d+)\*\*', md):
        k = int(m.group(1))
        start = md.find('```', m.end())
        end = md.find('```', start + 3) if start >= 0 else -1
        if start < 0 or end < 0:
            samples[k] = None
            continue
        body = md[start + 3:end].replace('\r\n', '\n').strip('\n')
        lines = body.split('\n')
        try:
            i_in = next(i for i, ln in enumerate(lines) if ln.strip() in ('输入：', '输入:'))
            i_out = next(i for i, ln in enumerate(lines) if ln.strip() in ('输出：', '输出:'))
        except StopIteration:
            samples[k] = None
            continue
        inp = lines[i_in + 1:i_out]
        out = lines[i_out + 1:]
        samples[k] = (norm_lines('\n'.join(inp)), norm_lines('\n'.join(out)))
    return samples


_NOTES_CACHE = {}


def check_notes(level):
    """notes\\D<nn>.md must exist with 4x (学术 / 实操 / 建议), 建议 last."""
    if level in _NOTES_CACHE:
        return _NOTES_CACHE[level]
    path = os.path.join(NOTES_DIR, 'D%02d.md' % level)
    errs = []
    if not os.path.isfile(path):
        errs.append('missing notes file: notes\\D%02d.md' % level)
    else:
        try:
            txt, e = read_text(path)
        except OSError as ex:
            txt, e = None, [str(ex)]
        errs += e
        if txt:
            for sec in ('### 学术', '### 实操', '### 建议'):
                cnt = txt.count(sec)
                if cnt < 4:
                    errs.append('notes\\D%02d.md has %d "%s" sections, need 4' % (level, cnt, sec))
            if txt.find('### 建议') < txt.find('### 学术'):
                errs.append('notes\\D%02d.md: 建议 must come after 学术')
    _NOTES_CACHE[level] = errs
    return errs


def check_problem(pdir):
    name = os.path.basename(pdir)
    errs = list(check_notes(int(name.split('-')[0][1:])))
    warns = []

    md_path = os.path.join(pdir, '题面.md')
    if not os.path.isfile(md_path):
        return ['missing 题面.md'], warns
    md, e = read_text(md_path)
    errs += e
    if md is None:
        return errs, warns

    if '\r' in md.replace('\r\n', '\n'):
        errs.append('statement has a bare CR')
    if not md.startswith('# '):
        errs.append('题面.md must start with "# <ID> · <title>"')
    if ('`answers/%s.cj`' % name) not in md:
        errs.append('题面 must contain `answers/%s.cj` as the submit path' % name)
    for sec in REQUIRED_SECTIONS:
        if sec not in md:
            errs.append('missing section/field: %s' % sec)
    for sec in FORBIDDEN_SECTIONS:
        if sec in md:
            errs.append('statement must not contain "%s" (move it to notes\\D<nn>.md)' % sec)
    if 'notes' not in md:
        errs.append('statement must link its notes file (e.g. 知识点与建议：`..\\..\\notes\\D08.md`)')
    if '数据范围' not in md:
        errs.append('missing the 数据范围 line')
    for bad in ('TODO', 'FIXME', '答错'):
        if bad in md:
            errs.append('placeholder left in 题面: %s' % bad)

    ind = os.path.join(pdir, 'in')
    outd = os.path.join(pdir, 'out')
    for d in (ind, outd):
        if not os.path.isdir(d):
            errs.append('missing dir: %s' % os.path.basename(d))
    if errs:
        return errs, warns

    ins = sorted(f for f in os.listdir(ind) if f.endswith('.txt'))
    outs = sorted(f for f in os.listdir(outd) if f.endswith('.txt'))
    if ins != outs:
        errs.append('in/ and out/ file names differ: in=%s out=%s' % (ins, outs))
    if len(ins) < 4:
        errs.append('only %d cases, need at least 4' % len(ins))
    expect = ['%02d.txt' % i for i in range(1, len(ins) + 1)]
    if ins != expect:
        errs.append('case names must run 01..%02d, got %s' % (len(ins), ins))

    contents = {}
    for fn in ins:
        if fn not in outs:
            continue
        for sub in ('in', 'out'):
            p = os.path.join(pdir, sub, fn)
            tag = '%s/%s' % (sub, fn)
            if os.path.getsize(p) > MAX_BYTES:
                errs.append('%s exceeds 8 MB' % tag)
            txt, e2 = read_text(p)
            errs += ['%s: %s' % (tag, x) for x in e2]
            if txt is None:
                continue
            if '\r\n' in txt:
                errs.append('%s uses CRLF, must be LF' % tag)
            if not txt.endswith('\n'):
                errs.append('%s has no trailing newline' % tag)
            elif txt.endswith('\n\n'):
                errs.append('%s ends with a blank line' % tag)
            if txt.strip() == '':
                errs.append('%s is empty' % tag)
            if sub == 'out':
                for i, ln in enumerate(txt.split('\n')):
                    if ln != ln.rstrip():
                        errs.append('%s line %d has trailing spaces' % (tag, i + 1))
                        break
                if any(ord(ch) > 127 for ch in txt):
                    warns.append('%s contains non-ASCII (make sure that is intended)' % tag)
            contents[(sub, fn)] = txt

    samples = parse_samples(md)
    if not samples:
        errs.append('no "样例 k" block parsed from 题面.md')
    else:
        for k in sorted(samples):
            fn = '%02d.txt' % k
            if fn not in ins:
                errs.append('题面 has 样例 %d but in/%s is missing' % (k, fn))
                continue
            got = samples[k]
            if got is None:
                errs.append('样例 %d block malformed (needs "输入：" / "输出：" marker lines)' % k)
                continue
            exp_in = norm_lines(contents.get(('in', fn), ''))
            exp_out = norm_lines(contents.get(('out', fn), ''))
            if got[0] != exp_in:
                errs.append('样例 %d input does not match in/%s' % (k, fn))
            if got[1] != exp_out:
                errs.append('样例 %d output does not match out/%s' % (k, fn))
        if 1 not in samples or 2 not in samples:
            errs.append('need 样例 1 and 样例 2 (they must equal in/01, in/02)')
    return errs, warns


def main():
    filt = sys.argv[1] if len(sys.argv) > 1 else ''
    if not os.path.isdir(PROB):
        print('no problems dir: %s' % PROB)
        return 2
    names = sorted(d for d in os.listdir(PROB)
                   if os.path.isdir(os.path.join(PROB, d)) and re.match(r'^D\d+-', d))
    if filt:
        names = [n for n in names if n == filt or n.startswith(filt + '-')]
    if not names:
        print('no problem matched filter %r' % filt)
        return 2

    bad = 0
    for n in names:
        errs, warns = check_problem(os.path.join(PROB, n))
        if errs:
            bad += 1
            print('FAIL %s' % n)
            for e in errs:
                print('     x %s' % e)
        else:
            print('  ok %s' % n)
        for w in warns:
            print('     ! %s' % w)
    print('\n%d problem(s) checked, %d FAIL' % (len(names), bad))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
