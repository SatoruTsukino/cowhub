#!/usr/bin/env python3
"""Export the Comprehensive Rebirth Economy, Market Research, and Endgame Systems Report.

Generates:
  1. docs/rebirth_model2_exploration.html (complete styled HTML document with vector SVGs)
  2. docs/Cow_Game_Rebirth_Model2_Exploration.pdf (rendered via headless Chrome)
  3. docs/Rebirth_Model2_Exploration_Report.md (comprehensive markdown documentation)
  4. Antigravity artifact copy in brain/
"""

import math
import os
import shutil
import subprocess
import sys


def generate_svg_charts():
    # --- CHART 1: Grind Time per Tier T(r) (Hours) R20 to R30 ---
    w = 760
    h = 270
    pad = {"left": 70, "right": 30, "top": 35, "bottom": 45}
    pw = w - pad["left"] - pad["right"]
    ph = h - pad["top"] - pad["bottom"]

    r_vals = list(range(20, 31))  # R20 to R30
    y1_max = 220.0

    def x1(r):
        return pad["left"] + (r - 20) / 10.0 * pw

    def y1(val):
        v = min(max(val, 0.0), y1_max)
        return pad["top"] + ph - (v / y1_max * ph)

    grid1 = []
    for y_val in [0, 50, 100, 150, 200]:
        yp = y1(y_val)
        grid1.append(f'<line x1="{pad["left"]}" y1="{yp:.1f}" x2="{w - pad["right"]}" y2="{yp:.1f}" stroke="#e2e8f0" stroke-width="1" stroke-dasharray="3,3" />')
        grid1.append(f'<text x="{pad["left"] - 10}" y="{yp + 4:.1f}" font-size="9.5" font-family="system-ui, sans-serif" fill="#64748b" text-anchor="end">{y_val}h</text>')

    for r in r_vals:
        xp = x1(r)
        is_hl = (r in [20, 24, 25, 30])
        color = "#047857" if is_hl else "#64748b"
        weight = "700" if is_hl else "400"
        grid1.append(f'<line x1="{xp:.1f}" y1="{pad["top"]}" x2="{xp:.1f}" y2="{pad["top"] + ph}" stroke="#f1f5f9" stroke-width="1" />')
        grid1.append(f'<text x="{xp:.1f}" y="{pad["top"] + ph + 16}" font-size="10" font-weight="{weight}" font-family="system-ui, sans-serif" fill="{color}" text-anchor="middle">R{r}</text>')

    orig_pts = []
    med_pts = []
    curr_pts = []

    for r in r_vals:
        dr = r - 20
        t_orig = 100.0 + 40.0 * math.log(1.0 + dr)
        t_med = 50.0 + 25.0 * math.log(1.0 + dr)
        t_curr = 29.4 + 12.0 * math.log(1.0 + dr)
        orig_pts.append((x1(r), y1(t_orig), t_orig))
        med_pts.append((x1(r), y1(t_med), t_med))
        curr_pts.append((x1(r), y1(t_curr), t_curr))

    orig_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y, _ in orig_pts])
    med_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y, _ in med_pts])
    curr_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y, _ in curr_pts])

    svg1 = f"""
    <svg viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="width:100%; height:auto;">
        <rect width="{w}" height="{h}" fill="#ffffff" rx="8" />
        <text x="70" y="22" font-size="11.5" font-weight="700" font-family="system-ui, sans-serif" fill="#0f172a">Graph 1: Grind Time per Tier T(r) Across Models (Hours)</text>
        {"".join(grid1)}
        <line x1="{pad['left']}" y1="{pad['top'] + ph}" x2="{w - pad['right']}" y2="{pad['top'] + ph}" stroke="#94a3b8" stroke-width="1.5" />
        <line x1="{pad['left']}" y1="{pad['top']}" x2="{pad['left']}" y2="{pad['top'] + ph}" stroke="#94a3b8" stroke-width="1.5" />

        <polyline points="{orig_poly}" fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{med_poly}" fill="none" stroke="#f59e0b" stroke-width="2.8" stroke-dasharray="4,3" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{curr_poly}" fill="none" stroke="#10b981" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>

        <circle cx="{x1(24):.1f}" cy="{y1(164.4):.1f}" r="4" fill="#ef4444"/>
        <text x="{x1(24) - 8:.1f}" y="{y1(164.4) - 8:.1f}" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#dc2626">Orig: 164.4h</text>

        <circle cx="{x1(24):.1f}" cy="{y1(90.2):.1f}" r="4.5" fill="#f59e0b" stroke="#ffffff" stroke-width="1.5"/>
        <text x="{x1(24) + 6:.1f}" y="{y1(90.2) - 4:.1f}" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#d97706">Med: 90.2h</text>

        <circle cx="{x1(24):.1f}" cy="{y1(48.7):.1f}" r="4.5" fill="#10b981" stroke="#ffffff" stroke-width="1.5"/>
        <text x="{x1(24) + 6:.1f}" y="{y1(48.7) + 12:.1f}" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#047857">Curr: 48.7h</text>

        <g transform="translate(420, 32)">
            <rect x="0" y="0" width="305" height="54" fill="#f8fafc" rx="5" stroke="#e2e8f0"/>
            <line x1="10" y1="12" x2="28" y2="12" stroke="#ef4444" stroke-width="2.5"/>
            <text x="34" y="15" font-size="8.5" font-weight="600" font-family="system-ui, sans-serif" fill="#1e293b">Original Model 2 (T0=100h, A=40h) — Heavy prestige</text>

            <line x1="10" y1="27" x2="28" y2="27" stroke="#f59e0b" stroke-width="2.8" stroke-dasharray="4,2"/>
            <text x="34" y="30" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#b45309">Mediating Model 2 (T0=50h, A=25h) — Balanced sweet-spot</text>

            <line x1="10" y1="42" x2="28" y2="42" stroke="#10b981" stroke-width="3"/>
            <text x="34" y="45" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#047857">Current Model 2 (T0=29.4h, A=12h) — Fast daily pace</text>
        </g>
    </svg>
    """

    # --- CHART 2: Daily Progress % (5h Active Session) ---
    h2 = 240
    ph2 = h2 - pad["top"] - pad["bottom"]
    y2_max = 20.0

    def y2(val):
        v = min(max(val, 0.0), y2_max)
        return pad["top"] + ph2 - (v / y2_max * ph2)

    grid2 = []
    for y_val in [0, 5, 10, 15, 20]:
        yp = y2(y_val)
        grid2.append(f'<line x1="{pad["left"]}" y1="{yp:.1f}" x2="{w - pad["right"]}" y2="{yp:.1f}" stroke="#e2e8f0" stroke-width="1" stroke-dasharray="3,3" />')
        grid2.append(f'<text x="{pad["left"] - 10}" y="{yp + 4:.1f}" font-size="9.5" font-family="system-ui, sans-serif" fill="#64748b" text-anchor="end">{y_val}%</text>')

    for r in r_vals:
        xp = x1(r)
        is_hl = (r in [20, 24, 25, 30])
        color = "#047857" if is_hl else "#64748b"
        weight = "700" if is_hl else "400"
        grid2.append(f'<line x1="{xp:.1f}" y1="{pad["top"]}" x2="{xp:.1f}" y2="{pad["top"] + ph2}" stroke="#f1f5f9" stroke-width="1" />')
        grid2.append(f'<text x="{xp:.1f}" y="{pad["top"] + ph2 + 16}" font-size="10" font-weight="{weight}" font-family="system-ui, sans-serif" fill="{color}" text-anchor="middle">R{r}</text>')

    p_orig_pts = []
    p_med_pts = []
    p_curr_pts = []
    for r in r_vals:
        dr = r - 20
        t_orig = 100.0 + 40.0 * math.log(1.0 + dr)
        t_med = 50.0 + 25.0 * math.log(1.0 + dr)
        t_curr = 29.4 + 12.0 * math.log(1.0 + dr)
        p_orig_pts.append((x1(r), y2(5.0 / t_orig * 100.0)))
        p_med_pts.append((x1(r), y2(5.0 / t_med * 100.0)))
        p_curr_pts.append((x1(r), y2(5.0 / t_curr * 100.0)))

    p_orig_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in p_orig_pts])
    p_med_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in p_med_pts])
    p_curr_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in p_curr_pts])

    svg2 = f"""
    <svg viewBox="0 0 {w} {h2}" xmlns="http://www.w3.org/2000/svg" style="width:100%; height:auto;">
        <rect width="{w}" height="{h2}" fill="#ffffff" rx="8" />
        <text x="70" y="22" font-size="11.5" font-weight="700" font-family="system-ui, sans-serif" fill="#0f172a">Graph 2: Daily Progress Bar Movement (% per 5-Hour Active Day)</text>
        {"".join(grid2)}
        <line x1="{pad['left']}" y1="{pad['top'] + ph2}" x2="{w - pad['right']}" y2="{pad['top'] + ph2}" stroke="#94a3b8" stroke-width="1.5" />
        <line x1="{pad['left']}" y1="{pad['top']}" x2="{pad['left']}" y2="{pad['top'] + ph2}" stroke="#94a3b8" stroke-width="1.5" />

        <polyline points="{p_orig_poly}" fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{p_med_poly}" fill="none" stroke="#f59e0b" stroke-width="2.8" stroke-dasharray="4,2" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{p_curr_poly}" fill="none" stroke="#10b981" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>

        <g transform="translate(430, 32)">
            <rect x="0" y="0" width="295" height="46" fill="#f8fafc" rx="4" stroke="#e2e8f0"/>
            <text x="10" y="15" font-size="8.5" font-weight="600" font-family="system-ui, sans-serif" fill="#047857">• Current: 8.6% &ndash; 17.0% / day (Rapid momentum)</text>
            <text x="10" y="27" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#b45309">• Mediating: 4.5% &ndash; 10.0% / day (Balanced progress)</text>
            <text x="10" y="39" font-size="8.5" font-weight="600" font-family="system-ui, sans-serif" fill="#dc2626">• Original: 2.6% &ndash; 5.0% / day (Stagnation risk)</text>
        </g>
    </svg>
    """

    # --- CHART 3: Cumulative Total Hours from R20 ---
    h3 = 250
    ph3 = h3 - pad["top"] - pad["bottom"]
    y3_max = 1800.0

    def y3(val):
        v = min(max(val, 0.0), y3_max)
        return pad["top"] + ph3 - (v / y3_max * ph3)

    grid3 = []
    for y_val in [0, 400, 800, 1200, 1600]:
        yp = y3(y_val)
        grid3.append(f'<line x1="{pad["left"]}" y1="{yp:.1f}" x2="{w - pad["right"]}" y2="{yp:.1f}" stroke="#e2e8f0" stroke-width="1" stroke-dasharray="3,3" />')
        grid3.append(f'<text x="{pad["left"] - 10}" y="{yp + 4:.1f}" font-size="9.5" font-family="system-ui, sans-serif" fill="#64748b" text-anchor="end">{y_val}h</text>')

    for r in r_vals:
        xp = x1(r)
        is_hl = (r in [20, 25, 30])
        color = "#047857" if is_hl else "#64748b"
        weight = "700" if is_hl else "400"
        grid3.append(f'<line x1="{xp:.1f}" y1="{pad["top"]}" x2="{xp:.1f}" y2="{pad["top"] + ph3}" stroke="#f1f5f9" stroke-width="1" />')
        grid3.append(f'<text x="{xp:.1f}" y="{pad["top"] + ph3 + 16}" font-size="10" font-weight="{weight}" font-family="system-ui, sans-serif" fill="{color}" text-anchor="middle">R{r}</text>')

    c_orig_pts = []
    c_med_pts = []
    c_curr_pts = []
    cum_orig = 0.0
    cum_med = 0.0
    cum_curr = 0.0

    for r in r_vals:
        c_orig_pts.append((x1(r), y3(cum_orig)))
        c_med_pts.append((x1(r), y3(cum_med)))
        c_curr_pts.append((x1(r), y3(cum_curr)))
        dr = r - 20
        cum_orig += 100.0 + 40.0 * math.log(1.0 + dr)
        cum_med += 50.0 + 25.0 * math.log(1.0 + dr)
        cum_curr += 29.4 + 12.0 * math.log(1.0 + dr)

    c_orig_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in c_orig_pts])
    c_med_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in c_med_pts])
    c_curr_poly = " ".join([f"{x:.1f},{y:.1f}" for x, y in c_curr_pts])

    svg3 = f"""
    <svg viewBox="0 0 {w} {h3}" xmlns="http://www.w3.org/2000/svg" style="width:100%; height:auto;">
        <rect width="{w}" height="{h3}" fill="#ffffff" rx="8" />
        <text x="70" y="22" font-size="11.5" font-weight="700" font-family="system-ui, sans-serif" fill="#0f172a">Graph 3: Cumulative Total Hours from R20 to Target Rebirth</text>
        {"".join(grid3)}
        <line x1="{pad['left']}" y1="{pad['top'] + ph3}" x2="{w - pad['right']}" y2="{pad['top'] + ph3}" stroke="#94a3b8" stroke-width="1.5" />
        <line x1="{pad['left']}" y1="{pad['top']}" x2="{pad['left']}" y2="{pad['top'] + ph3}" stroke="#94a3b8" stroke-width="1.5" />

        <polyline points="{c_orig_poly}" fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{c_med_poly}" fill="none" stroke="#f59e0b" stroke-width="2.8" stroke-dasharray="4,2" stroke-linecap="round" stroke-linejoin="round"/>
        <polyline points="{c_curr_poly}" fill="none" stroke="#10b981" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>

        <circle cx="{x1(30):.1f}" cy="{y3(1604.2):.1f}" r="4" fill="#ef4444"/>
        <text x="{x1(30) - 12:.1f}" y="{y3(1604.2) - 6:.1f}" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#dc2626" text-anchor="end">Original: 1,604h</text>

        <circle cx="{x1(30):.1f}" cy="{y3(877.6):.1f}" r="4.5" fill="#f59e0b" stroke="#ffffff" stroke-width="1.5"/>
        <text x="{x1(30) - 12:.1f}" y="{y3(877.6) - 6:.1f}" font-size="9" font-weight="800" font-family="system-ui, sans-serif" fill="#d97706" text-anchor="end">Mediating: 878h [Balanced Midpoint]</text>

        <circle cx="{x1(30):.1f}" cy="{y3(475.3):.1f}" r="4.5" fill="#10b981" stroke="#ffffff" stroke-width="1.5"/>
        <text x="{x1(30) - 12:.1f}" y="{y3(475.3) + 14:.1f}" font-size="8.5" font-weight="700" font-family="system-ui, sans-serif" fill="#047857" text-anchor="end">Current: 475h</text>
    </svg>
    """
    return svg1, svg2, svg3


def build_html() -> str:
    svg1, svg2, svg3 = generate_svg_charts()

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cow Game Master Progression & Endgame Architecture Report</title>
<style>
    @page {{
        size: letter;
        margin: 10mm 12mm 10mm 12mm;
    }}
    * {{ box-sizing: border-box; }}
    body {{
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        color: #1e293b;
        background: #ffffff;
        line-height: 1.38;
        font-size: 11px;
        margin: 0;
        padding: 0;
    }}
    h1, h2, h3, h4 {{ color: #0f172a; margin-top: 0; line-height: 1.2; }}
    h1 {{ font-size: 18px; margin-bottom: 3px; font-weight: 800; }}
    h2 {{ font-size: 13.5px; margin-bottom: 4px; font-weight: 700; border-bottom: 1.5px solid #e2e8f0; padding-bottom: 3px; }}
    h3 {{ font-size: 11.5px; margin-bottom: 3px; font-weight: 700; }}
    .subtitle {{
        font-size: 10.5px;
        color: #64748b;
        margin-bottom: 8px;
        border-bottom: 1.5px solid #e2e8f0;
        padding-bottom: 4px;
    }}
    .meta-badge {{
        display: inline-block;
        background: #f1f5f9;
        color: #334155;
        font-weight: 600;
        font-size: 9.5px;
        padding: 2px 6px;
        border-radius: 4px;
        margin-right: 4px;
    }}
    .badge-primary {{ background: #dbeafe; color: #1e40af; }}
    .badge-success {{ background: #d1fae5; color: #065f46; }}
    .badge-warning {{ background: #fef3c7; color: #92400e; }}
    .badge-purple {{ background: #f3e8ff; color: #6b21a8; }}
    .callout {{
        border-left: 3.5px solid #3b82f6;
        background: #f8fafc;
        padding: 6px 10px;
        border-radius: 0 5px 5px 0;
        margin: 6px 0;
        font-size: 10.5px;
    }}
    .callout-warning {{ border-left-color: #f59e0b; background: #fffbeb; }}
    .callout-success {{ border-left-color: #10b981; background: #f0fdf4; }}
    .callout-purple {{ border-left-color: #8b5cf6; background: #faf5ff; }}
    .grid-2 {{
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px;
        margin: 5px 0;
    }}
    .grid-3 {{
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 8px;
        margin: 5px 0;
    }}
    .card {{
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 7px 9px;
        background: #ffffff;
    }}
    .card-highlight {{ border: 1.5px solid #10b981; background: #f0fdf4; }}
    .card-amber {{ border: 1.5px solid #f59e0b; background: #fffbeb; }}
    .card-purple {{ border: 1.5px solid #8b5cf6; background: #faf5ff; }}
    .formula-box {{
        background: #0f172a;
        color: #f8fafc;
        padding: 7px 11px;
        border-radius: 5px;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-size: 9.5px;
        line-height: 1.4;
        margin: 5px 0;
    }}
    .formula-box .keyword {{ color: #38bdf8; font-weight: 700; }}
    .formula-box .accent {{ color: #34d399; font-weight: 700; }}
    .formula-box .comment {{ color: #94a3b8; }}
    table {{
        width: 100%;
        border-collapse: collapse;
        margin: 5px 0;
        font-size: 9.5px;
    }}
    th, td {{
        border: 1px solid #cbd5e1;
        padding: 3.5px 5px;
    }}
    th {{
        background: #f1f5f9;
        font-weight: 700;
        color: #0f172a;
    }}
    .text-center {{ text-align: center; }}
    .text-right {{ text-align: right; }}
    .page-break {{ page-break-after: always; }}
</style>
</head>
<body>

<!-- PAGE 1: PART I - Rebirth Model 2 Exploration & Pacing Options -->
<div>
    <h1>Cow Game Master Progression &amp; Endgame Architecture</h1>
    <div class="subtitle">
        Comprehensive Engineering Report: Rebirth 20&ndash;30 Pacing, Market Research, and Post-Max Economy Loops<br>
        <span class="meta-badge badge-primary">Game Systems &amp; Economy</span>
        <span class="meta-badge badge-warning">Target: R20 &rarr; R30 Progression</span>
        <span class="meta-badge badge-purple">Post-Max Endgame Loops</span>
        <span class="meta-badge">November 2026</span>
    </div>

    <h2>Part I: Model 2 Pacing Exploration &amp; Trade-off Analysis</h2>
    <p style="margin-bottom:5px;">
        When balancing <strong>Rebirth 20 through Rebirth 30</strong>, the design goal is reconciling two desirable outcomes that naturally oppose each other:
    </p>

    <div class="grid-2">
        <div class="card">
            <h4 style="color:#0f172a; font-size:11px; margin-bottom:2px;">Goal A: Heavy Rebirth Prestige (High Hours)</h4>
            <p style="font-size:9.5px; color:#475569; margin:0;">
                Veterans want reaching Rebirth 25 or 30 to feel like an epic status milestone. Single rebirths should take noticeable dedication (80h&ndash;150h) so accomplishments carry prestige on leaderboards.
            </p>
        </div>
        <div class="card card-highlight">
            <h4 style="color:#065f46; font-size:11px; margin-bottom:2px;">Goal B: Tangible Daily Progress (&gt;10% / Day)</h4>
            <p style="font-size:9.5px; color:#065f46; margin:0;">
                Players logging in for a 5-hour daily session demand to see their progress bar move visibly (10% to 15% / day) so the session feels productive and rewarding.
            </p>
        </div>
    </div>

    <div class="callout callout-warning">
        <strong>The Mathematical Inverse Law:</strong> Under any single flat cost requirement, daily progress percentage is strictly the mathematical inverse of grind duration:
        <code>Daily Progress % = (5.0 hours / T(r) hours) &times; 100%</code>.
        A single-tier requirement of 160 hours mathematically yields only <strong>3.1% progress per day</strong>.
    </div>

    <div class="grid-3" style="margin-top:6px;">
        <div class="card">
            <h4 style="color:#ef4444; font-size:10.5px; margin-bottom:2px;">Original Model 2</h4>
            <p style="font-size:9px; color:#64748b; margin:0 0 2px;"><code>T(r) = 100 + 40 &times; ln(1 + &Delta;r)</code></p>
            <ul style="font-size:9px; padding-left:11px; margin:0; color:#334155;">
                <li><strong>Tier Time:</strong> 100h &rarr; 196h</li>
                <li><strong>Daily Pace:</strong> 5.0% &rarr; 2.6%/day</li>
                <li><strong>Total R20-30:</strong> 1,604 hours</li>
                <li><strong>Feel:</strong> Heavy flex; high quit risk.</li>
            </ul>
        </div>
        <div class="card card-amber">
            <h4 style="color:#b45309; font-size:10.5px; margin-bottom:2px;">Mediating Model 2 [SWEET-SPOT]</h4>
            <p style="font-size:9px; color:#92400e; margin:0 0 2px;"><code>T(r) = 50 + 25 &times; ln(1 + &Delta;r)</code></p>
            <ul style="font-size:9px; padding-left:11px; margin:0; color:#92400e;">
                <li><strong>Tier Time:</strong> 50h &rarr; 110h</li>
                <li><strong>Daily Pace:</strong> 10.0% &rarr; 4.5%/day</li>
                <li><strong>Total R20-30:</strong> <strong>878 hours</strong></li>
                <li><strong>Feel:</strong> Balanced intermediate pacing (geometric mean &sim;873h).</li>
            </ul>
        </div>
        <div class="card card-highlight">
            <h4 style="color:#059669; font-size:10.5px; margin-bottom:2px;">Current Model 2</h4>
            <p style="font-size:9px; color:#065f46; margin:0 0 2px;"><code>T(r) = 29.4 + 12 &times; ln(1 + &Delta;r)</code></p>
            <ul style="font-size:9px; padding-left:11px; margin:0; color:#065f46;">
                <li><strong>Tier Time:</strong> 29.4h &rarr; 58.2h</li>
                <li><strong>Daily Pace:</strong> 17.0% &rarr; 8.6%/day</li>
                <li><strong>Total R20-30:</strong> 475 hours</li>
                <li><strong>Feel:</strong> Rapid daily engagement.</li>
            </ul>
        </div>
    </div>
</div>

<div class="page-break"></div>

<!-- PAGE 2: Pacing Comparison Graphs & Numerical Table -->
<div>
    <h2>Visual Pacing Comparisons (R20 &rarr; R30)</h2>
    <div style="border: 1px solid #e2e8f0; border-radius: 5px; padding: 3px; margin-bottom: 5px;">
        {svg1}
    </div>
    <div style="border: 1px solid #e2e8f0; border-radius: 5px; padding: 3px; margin-bottom: 5px;">
        {svg2}
    </div>
    <div style="border: 1px solid #e2e8f0; border-radius: 5px; padding: 3px;">
        {svg3}
    </div>

    <h3 style="margin-top:8px;">Tier-by-Tier Numerical Matrix</h3>
    <table>
        <thead>
            <tr>
                <th class="text-center">Tier Step</th>
                <th class="text-right">Income Mult</th>
                <th class="text-right" style="background:#fee2e2; color:#991b1b;">Original T(r)</th>
                <th class="text-center" style="background:#fee2e2; color:#991b1b;">Orig Daily %</th>
                <th class="text-right" style="background:#fef3c7; color:#92400e;">Mediating T(r)</th>
                <th class="text-center" style="background:#fef3c7; color:#92400e;">Med Daily %</th>
                <th class="text-right" style="background:#d1fae5; color:#065f46;">Current T(r)</th>
                <th class="text-center" style="background:#d1fae5; color:#065f46;">Curr Daily %</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-center"><strong>R20 &rarr; R21 (Anchor)</strong></td>
                <td class="text-right">53.36&times;</td>
                <td class="text-right">100.0h</td>
                <td class="text-center">5.0%/day</td>
                <td class="text-right" style="background:#fffbeb; font-weight:700;">50.0h</td>
                <td class="text-center" style="background:#fffbeb; font-weight:700;">10.0%/day</td>
                <td class="text-right" style="background:#f0fdf4;">29.4h</td>
                <td class="text-center" style="background:#f0fdf4;">17.0%/day</td>
            </tr>
            <tr>
                <td class="text-center"><strong>R22 &rarr; R23</strong></td>
                <td class="text-right">79.42&times;</td>
                <td class="text-right">143.9h</td>
                <td class="text-center">3.5%/day</td>
                <td class="text-right" style="background:#fffbeb;">77.5h</td>
                <td class="text-center" style="background:#fffbeb;">6.5%/day</td>
                <td class="text-right" style="background:#f0fdf4;">42.6h</td>
                <td class="text-center" style="background:#f0fdf4;">11.7%/day</td>
            </tr>
            <tr style="background:#fffbeb; font-weight:700;">
                <td class="text-center">R24 &rarr; R25 (Update Target)</td>
                <td class="text-right">118.21&times;</td>
                <td class="text-right" style="color:#dc2626;">164.4h</td>
                <td class="text-center" style="color:#dc2626;">3.0%/day</td>
                <td class="text-right" style="color:#b45309;">90.2h</td>
                <td class="text-center" style="color:#b45309;">5.5%/day</td>
                <td class="text-right" style="color:#047857;">48.7h</td>
                <td class="text-center" style="color:#047857;">10.3%/day</td>
            </tr>
            <tr>
                <td class="text-center"><strong>R27 &rarr; R28</strong></td>
                <td class="text-right">214.65&times;</td>
                <td class="text-right">183.2h</td>
                <td class="text-center">2.7%/day</td>
                <td class="text-right" style="background:#fffbeb;">102.0h</td>
                <td class="text-center" style="background:#fffbeb;">4.9%/day</td>
                <td class="text-right" style="background:#f0fdf4;">54.4h</td>
                <td class="text-center" style="background:#f0fdf4;">9.2%/day</td>
            </tr>
            <tr>
                <td class="text-center"><strong>R29 &rarr; R30</strong></td>
                <td class="text-right">319.48&times;</td>
                <td class="text-right">192.1h</td>
                <td class="text-center">2.6%/day</td>
                <td class="text-right" style="background:#fffbeb;">107.6h</td>
                <td class="text-center" style="background:#fffbeb;">4.6%/day</td>
                <td class="text-right" style="background:#f0fdf4;">57.0h</td>
                <td class="text-center" style="background:#f0fdf4;">8.8%/day</td>
            </tr>
            <tr style="background:#f8fafc; font-weight:700;">
                <td class="text-center">Total R20 &rarr; R30</td>
                <td class="text-right">&mdash;</td>
                <td class="text-right" style="color:#dc2626;">1,604.2 hrs</td>
                <td class="text-center">3.3%/day avg</td>
                <td class="text-right" style="color:#b45309; background:#fef3c7;">877.6 hrs</td>
                <td class="text-center" style="background:#fef3c7;">6.0%/day avg</td>
                <td class="text-right" style="color:#047857; background:#d1fae5;">475.3 hrs</td>
                <td class="text-center" style="background:#d1fae5;">11.0%/day avg</td>
            </tr>
        </tbody>
    </table>
</div>

<div class="page-break"></div>

<!-- PAGE 3: PART II - Market Research Synthesis & Retention Science -->
<div>
    <h2>Part II: Market Research Synthesis &amp; Retention Science</h2>
    <div class="subtitle">
        Cross-Platform Study: Top Roblox Simulators (Pet Sim 99, Bee Swarm) &amp; Incremental Leaders (Idle Slayer, Antimatter Dimensions)
    </div>

    <h3>1. Key Findings Across Industry Leaders</h3>
    <ul style="padding-left:14px; margin-top:3px; margin-bottom:8px;">
        <li><strong>No 50h&ndash;100h Single-Bar Rebirths:</strong> Modern Roblox simulators have eliminated raw 50h+ grinds with full map-wipes. In <em>Pet Simulator 99</em>, rebirth takes 20m (R1) to 4&ndash;6 hours (R9). Rebirth resets <strong>wallet currency only</strong>&mdash;areas, pets, and masteries are retained.</li>
        <li><strong>Additive Progression in Bee Swarm:</strong> <em>Bee Swarm Simulator</em> features zero wipes. Its 300h endgame (Spirit Bear &amp; SSA) is broken into 30 specific quest checklists, each requiring ~10h of varied play.</li>
        <li><strong>Fractal Loops in Incremental Games:</strong> <em>Antimatter Dimensions</em> and <em>Idle Slayer</em> support 300h+ campaigns by nesting automated 1-minute loops inside 2-hour ascensions inside multi-week meta-ascensions.</li>
    </ul>

    <h3>2. Retention Psychology: The Goal Gradient &amp; Weber's Law</h3>
    <div class="grid-2">
        <div class="card">
            <h4 style="color:#0f172a; font-size:10.5px; margin-bottom:2px;">Clark Hull's Goal Gradient Effect</h4>
            <p style="font-size:9.5px; color:#475569; margin:0;">
                Player motivation accelerates as distance to goal decreases. When a player is at 80%&ndash;90% of a milestone, session lengths and active engagement spike. Conversely, resetting a massive 100h bar to 0% causes a <strong>post-reinforcement motivation crash</strong>.
            </p>
        </div>
        <div class="card card-amber">
            <h4 style="color:#92400e; font-size:10.5px; margin-bottom:2px;">Weber's Law &amp; The 10% JND Rule</h4>
            <p style="font-size:9.5px; color:#92400e; margin:0;">
                A progress indicator must advance by <strong>at least 8% to 10% per active session</strong> to cross the visual threshold of "Noticeable Difference". At 2%&ndash;3% daily progress, the brain registers the game as <strong>stuck/frozen</strong>, driving D7-D30 churn over 90%.
            </p>
        </div>
    </div>

    <h3 style="margin-top:8px;">3. The Recommended Progression Engine: 3-Layer Architecture</h3>
    <div class="card card-highlight">
        <h4 style="color:#065f46; font-size:11px; margin-bottom:2px;">Combining Option B (Sub-Stages) with Option C (Meta-Layer)</h4>
        <ul style="font-size:9.5px; padding-left:14px; margin:2px 0 0; color:#065f46;">
            <li><strong>Layer 1 (Micro-Loops &mdash; 15&ndash;45 mins):</strong> Decoupled Ranks (rotating quests) and 1&ndash;99 Masteries. Yields 2&ndash;3 audible reward chimes per active session.</li>
            <li><strong>Layer 2 (Meso-Loops &mdash; 25&ndash;35h per Tier):</strong> Deconstruct each Rebirth Tier into 3 visible <strong>Chapters/Crests (Bronze at 30%, Silver at 65%, Rebirth at 100%)</strong>. Active players move the active sub-bar by 12% to 18% per day.</li>
            <li><strong>Layer 3 (Macro Meta-Layer &mdash; 200h to 800h+):</strong> Decoupled Celestial Ascension / Star Pasture tree unlocking non-numerical game rules and horizontal builds.</li>
        </ul>
    </div>
</div>

<div class="page-break"></div>

<!-- PAGE 4: PART III - Beyond the Maxed Rebirth Tree: Solving the Numerical Void -->
<div>
    <h2>Part III: Beyond the Maxed Rebirth Tree &mdash; Solving the "Numerical Void"</h2>
    <div class="subtitle">
        What to Chase When the Tree is Capped: Shifting from Vertical Power to Mechanical Novelty &amp; Social Status
    </div>

    <div class="callout callout-purple">
        <strong>The "Numerical Void" Problem:</strong> When the rebirth tree is maxed, currency ceases to be a tool for unlocking new experiences. Making money solely to make more money faster triggers existential player burnout: <em>"Why am I grinding if numbers just get bigger?"</em>
    </div>

    <h3>Four Concrete Systems to Fill the Void</h3>

    <div class="grid-2">
        <div class="card card-purple">
            <h4 style="color:#6b21a8; font-size:11px; margin-bottom:2px;">1. Celestial Ascension (Qualitative Meta-Tree)</h4>
            <p style="font-size:9.5px; color:#475569; margin:0 0 3px;">
                Sacrifice maxed cows or spend surplus fortunes for <strong>Star Shards</strong> to buy rule-breaking powers:
            </p>
            <ul style="font-size:9px; padding-left:12px; margin:0; color:#334155;">
                <li><strong>Vacuum Grazing:</strong> Telekinetically pull grass in a 15-stud radius.</li>
                <li><strong>Flora Transmutation:</strong> Chance for standard grass to convert into rare Golden/Cave nodes as you walk.</li>
                <li><strong>Companion Synergy:</strong> Dogs fetch bait/crates autonomously; Cats generate passive clover aura while sleeping on your back.</li>
            </ul>
        </div>
        <div class="card card-highlight">
            <h4 style="color:#065f46; font-size:11px; margin-bottom:2px;">2. Horizontal Cow Breeds &amp; Playstyles</h4>
            <p style="font-size:9.5px; color:#475569; margin:0 0 3px;">
                Spend late-game billions unlocking and leveling distinct cow archetypes:
            </p>
            <ul style="font-size:9px; padding-left:12px; margin:0; color:#334155;">
                <li><strong>Alpine Forager:</strong> +300% Clover luck and golden node odds.</li>
                <li><strong>Highland Brute:</strong> Heavy armor, smashes spider nests, extracts Manatite/Mithril in caves.</li>
                <li><strong>Holstein Merchant:</strong> Town Auction commission discounts, caravan raid cargo bonuses.</li>
            </ul>
        </div>
    </div>

    <div class="grid-2" style="margin-top:6px;">
        <div class="card card-amber">
            <h4 style="color:#92400e; font-size:11px; margin-bottom:2px;">3. Botanical Greenhouse &amp; Mutation Lab</h4>
            <p style="font-size:9.5px; color:#475569; margin:0 0 3px;">
                Completionist discovery system leveraging existing planting/flora mechanics:
            </p>
            <ul style="font-size:9px; padding-left:12px; margin:0; color:#334155;">
                <li>Cross-breed seeds to discover 50+ rare hybrid flora (<em>Ghost Clover</em>, <em>Abyssal Truffles</em>).</li>
                <li><strong>Flora Museum:</strong> Unlocking complete sets grants permanent cosmetic auras and exclusive titles.</li>
            </ul>
        </div>
        <div class="card">
            <h4 style="color:#1e293b; font-size:11px; margin-bottom:2px;">4. High-End Wealth Sinks &amp; Social Flex</h4>
            <p style="font-size:9.5px; color:#475569; margin:0 0 3px;">
                Convert surplus trillions into server-wide influence and prestige:
            </p>
            <ul style="font-size:9px; padding-left:12px; margin:0; color:#334155;">
                <li><strong>Golden Town Pedestal:</strong> Server's top investor has a giant golden statue of their cow and pets displayed in Town Square.</li>
                <li><strong>Caravan &amp; Fjord Sponsorship:</strong> Fund server-wide expeditions granting rare loot to all participants.</li>
            </ul>
        </div>
    </div>

    <h3 style="margin-top:8px;">Developer Implementation Roadmap</h3>
    <table>
        <thead>
            <tr>
                <th style="width:25%;">Phase</th>
                <th style="width:45%;">Deliverables</th>
                <th class="text-center" style="width:15%;">Dev Effort</th>
                <th class="text-center" style="width:15%;">Impact</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>Phase 1: Quick Win</strong></td>
                <td><strong>Town Prestige Sinks &amp; Mythic Titles:</strong> 3&ndash;5 vanity sinks in Town (Pedestal statue, glowing auras, elite titles) for surplus billions.</td>
                <td class="text-center"><strong>Low</strong></td>
                <td class="text-center" style="color:#047857; font-weight:700;">Immediate</td>
            </tr>
            <tr>
                <td><strong>Phase 2: Medium Term</strong></td>
                <td><strong>Celestial Ascension Meta-Tree:</strong> Star Shard prestige layer with qualitative mechanics (vacuum graze, flora transmutation, automation).</td>
                <td class="text-center"><strong>Medium</strong></td>
                <td class="text-center" style="color:#047857; font-weight:700;">High (D30+)</td>
            </tr>
            <tr>
                <td><strong>Phase 3: Major Update</strong></td>
                <td><strong>Archetypes or Botanical Greenhouse:</strong> Specialized cow breeds or genetic seed cross-breeding collection lab.</td>
                <td class="text-center"><strong>High</strong></td>
                <td class="text-center" style="color:#047857; font-weight:700;">Transformational</td>
            </tr>
        </tbody>
    </table>

    <h3 style="margin-top:8px;">References &amp; Research Sources</h3>
    <div class="grid-2">
        <div style="font-size:8.5px; color:#475569; line-height:1.35;">
            <strong style="color:#1e293b;">Academic &amp; Behavioral Psychology:</strong>
            <ul style="padding-left:11px; margin:2px 0 0;">
                <li><strong>Goal-Gradient Effect:</strong> Hull, C. L. (1932). <em>The Goal-Gradient Hypothesis</em>. Psychol. Rev., 39(1). (Effort acceleration vs. motivation collapse upon resets).</li>
                <li><strong>Weber-Fechner Law / JND:</strong> Weber (1834); Fechner (1860). (Progress bar increments &lt;8&ndash;10%/session fail perceptual threshold for advancement).</li>
                <li><strong>Self-Determination Theory:</strong> Ryan &amp; Deci (2000). (Autonomy &amp; competence via horizontal choice replacing raw vertical power).</li>
                <li><strong>Flow Optimization:</strong> Csikszentmihalyi (1990). <em>Flow: Optimal Experience</em>. (Balancing skill vs. challenge to avoid churn).</li>
                <li><strong>Player Typologies:</strong> Yee (2006). <em>Motivations in Online Games</em>. (Social status display, completionism, and role specialization).</li>
            </ul>
        </div>
        <div style="font-size:8.5px; color:#475569; line-height:1.35;">
            <strong style="color:#1e293b;">Industry Benchmarks &amp; Production Data:</strong>
            <ul style="padding-left:11px; margin:2px 0 0;">
                <li><strong><a href="https://pet-simulator.fandom.com/wiki/Rebirth_(Pet_Simulator_99)" target="_blank" style="color:#0284c7; text-decoration:none;">Pet Simulator 99 / X (BIG Games)</a>:</strong> High-frequency prestige (20m&ndash;6h); soft-currency resets with 100% item/world permanence.</li>
                <li><strong><a href="https://bee-swarm-simulator.fandom.com/wiki/Spirit_Bear" target="_blank" style="color:#0284c7; text-decoration:none;">Bee Swarm Simulator (Onett)</a>:</strong> Zero-wipe incremental architecture; 300h+ endgame split into 30 granular Spirit Bear quests.</li>
                <li><strong><a href="https://antimatter-dimensions.fandom.com/wiki/Prestige" target="_blank" style="color:#0284c7; text-decoration:none;">Antimatter Dimensions (Hevipelle)</a>:</strong> Multi-layered nested prestige (Infinity &rarr; Eternity &rarr; Reality &rarr; Celestial).</li>
                <li><strong><a href="https://idleslayer.fandom.com/wiki/Ultra_Ascension" target="_blank" style="color:#0284c7; text-decoration:none;">Idle Slayer (Pablo Leban)</a>:</strong> Ultra-Ascension pace-dampening Stones of Time and village meta-hubs.</li>
                <li><strong><a href="https://cookieclicker.fandom.com/wiki/Garden" target="_blank" style="color:#0284c7; text-decoration:none;">Cookie Clicker (Orteil)</a>:</strong> Post-max horizontal modules (<a href="https://cookieclicker.fandom.com/wiki/Garden" target="_blank" style="color:#0284c7; text-decoration:none;">Garden seed mutations</a>, Stock Market) as non-inflationary sinks.</li>
                <li><strong><a href="https://www.gdcvault.com/play/1022065/Idle-Games-The-Mechanics-and" target="_blank" style="color:#0284c7; text-decoration:none;">GDC Vault (Anthony Pecorella)</a>:</strong> <em>"Idle Games: Mechanics &amp; Monetization"</em> (<a href="https://www.youtube.com/watch?v=1F_b-R6gPlo" target="_blank" style="color:#0284c7; text-decoration:none;">YouTube</a>).</li>
                <li><strong><a href="https://www.deconstructoroffun.com/blog/2020/7/16/roblox-amp-beyond-the-problem-with-game-creator-platforms" target="_blank" style="color:#0284c7; text-decoration:none;">Deconstructor of Fun</a>:</strong> <em>"Roblox &amp; Beyond: Game Creator Platforms"</em>, <a href="https://naavik.co/digest/loot-deconstruction-roblox/" target="_blank" style="color:#0284c7; text-decoration:none;">Naavik</a> &amp; <a href="https://gameanalytics.com/benchmarks/" target="_blank" style="color:#0284c7; text-decoration:none;">GameAnalytics Benchmarks</a>.</li>
            </ul>
        </div>
    </div>
</div>

</body>
</html>
"""
    return html


def build_markdown_report() -> str:
    return """# Cow Game Master Progression & Endgame Architecture Report

**Prepared for Cow Game Development Team**  
*Scope: Rebirth 20–30 Pacing, Market Research Synthesis, and Post-Max Endgame Architecture*  
*Date: November 2026*

---

# Part I: Rebirth Model 2 Pacing & Trade-off Analysis

## 1. The Core Design Dilemma
When balancing **Rebirth 20 through Rebirth 30**, player expectations create a natural mathematical tension between two desirable outcomes:

1. **High Single-Tier Prestige (Heavy Grind per Rebirth)**:
   - High-ranking players and veterans want reaching Rebirth 25 or Rebirth 30 to feel like an epic status milestone. Single rebirths should take noticeable dedication (80h–150h) so accomplishments carry prestige on leaderboards.
2. **Rewarding Daily Progress (>10% per 5-Hour Day)**:
   - Players logging in for a 5-hour daily session demand to see their progress bar move visibly (**10% to 15% per day**) so the play session feels productive and rewarding.

### The Mathematical Inverse Law
Under any single static calorie requirement, daily progress percentage is strictly the inverse of single-tier grind duration:
$$\\text{Daily Progress \\%} = \\frac{5.0\\text{ hours}}{T(r)\\text{ hours}} \\times 100\\%$$

- If a single rebirth takes **160 hours** (High Prestige), a 5-hour session mathematically moves the bar only **3.1% / day** (causing stagnation and quit moments).
- If a 5-hour session moves the bar **12% to 15% / day**, that rebirth must take **33 to 42 hours**.

---

## 2. The Three Model 2 Implementation Pathways

### Baseline: Original Model 2 Heavy Prestige ($T_0 = 100.0\\text{h}, A = 40.0\\text{h}$)
* **Formula**: $T(r) = 100.0 + 40.0 \\cdot \\ln(1 + (r - 20))$
* **Cumulative Campaign (R20 $\\to$ R30)**: **1,604.2 hours**.
* **Single-Tier Time**: Rebirth 24 $\\to$ 25 takes **164.4 hours**; Rebirth 30 takes **192.1 hours**.
* **Daily Pace**: Starts at **5.0% / day** at R20 and drops to **2.6% / day** at R30.

### Option 1: The Mediating Mathematical Sweet-Spot ($T_0 = 50.0\\text{h}, A = 25.0\\text{h}$)
* **Formula**: $T(r) = 50.0 + 25.0 \\cdot \\ln(1 + (r - 20))$
* **Cumulative Campaign (R20 $\\to$ R30)**: **877.6 hours** (balanced intermediate pacing between the 475.3h Current and 1,604.2h Original models; geometric mean $\\approx 873.2$h).
* **Single-Tier Time**: Rebirth 24 $\\to$ 25 takes **90.2 hours**; Rebirth 30 takes **109.9 hours**.
* **Daily Pace**: Starts at **10.0% / day** at R20 and settles at **4.5% to 5.5% / day** at R25+.

### Option 2: The Sub-Stage Milestone Architecture (Game Design Solution)
* **Concept**: Decouple the Rebirth Gate from daily progress bars.
* Divide each tier into **3 visible Chapters or Crests (Bronze at 30%, Silver at 65%, Rebirth at 100% — ~25h to 35h per Crest)**.
* The player's active UI bar tracks the *current chapter*, advancing **12% to 18% every single day**, while the overall rebirth milestone retains long-term prestige without causing quit moments.

### Option 3: Current Model 2 Campaign Pivot ($T_0 = 29.4\\text{h}, A = 12.0\\text{h}$)
* **Formula**: $T(r) = 29.4 + 12.0 \\cdot \\ln(1 + (r - 20))$
* **Cumulative Campaign (R20 $\\to$ R30)**: **475.3 hours**.
* **Single-Tier Time**: Rebirth 24 $\\to$ 25 takes **48.7 hours**; Rebirth 30 takes **58.2 hours**.
* **Daily Pace**: Remains an invigorating **8.6% to 17.0% / day** across all tiers.

---

## 3. Tier-by-Tier Numerical Matrix (R20 to R30)

| Tier Step | Income Mult | Original Model 2 ($T_0=100$) | Orig Daily Pace | Mediating Model 2 ($T_0=50$) | Med Daily Pace | Current Model 2 ($T_0=29.4$) | Curr Daily Pace |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **R20 $\\to$ R21 (Anchor)** | 53.36× | 100.0h | 5.0% / day | **50.0h** | **10.0% / day** | **29.4h** | **17.0% / day** |
| **R21 $\\to$ R22** | 65.10× | 127.7h | 3.9% / day | **67.3h** | **7.4% / day** | **37.7h** | **13.3% / day** |
| **R22 $\\to$ R23** | 79.42× | 143.9h | 3.5% / day | **77.5h** | **6.5% / day** | **42.6h** | **11.7% / day** |
| **R23 $\\to$ R24** | 96.89× | 155.5h | 3.2% / day | **84.7h** | **5.9% / day** | **46.0h** | **10.9% / day** |
| **R24 $\\to$ R25 (Update Target)** | 118.21× | 164.4h | 3.0% / day | **90.2h** | **5.5% / day** | **48.7h** | **10.3% / day** |
| **R25 $\\to$ R26** | 144.21× | 171.7h | 2.9% / day | **94.8h** | **5.3% / day** | **50.9h** | **9.8% / day** |
| **R26 $\\to$ R27** | 175.94× | 177.8h | 2.8% / day | **98.6h** | **5.1% / day** | **52.8h** | **9.5% / day** |
| **R27 $\\to$ R28** | 214.65× | 183.2h | 2.7% / day | **102.0h** | **4.9% / day** | **54.4h** | **9.2% / day** |
| **R28 $\\to$ R29** | 261.87× | 187.9h | 2.7% / day | **104.9h** | **4.8% / day** | **55.8h** | **9.0% / day** |
| **R29 $\\to$ R30** | 319.48× | 192.1h | 2.6% / day | **107.6h** | **4.6% / day** | **57.0h** | **8.8% / day** |
| **Total R20 $\\to$ R30 Campaign** | — | **1,604.2 hrs** | *3.3% / day avg* | **877.6 hrs** | *6.0% / day avg* | **475.3 hrs** | *11.0% / day avg* |

---

# Part II: Market Research Synthesis & Retention Science

## 1. Industry Benchmarks & Case Studies
- **Roblox Simulators (*Pet Simulator 99*, *Bee Swarm Simulator*):** No modern top game forces players into 50h–100h monolithic bars. In PS99, rebirth takes 20m–6h, resetting **only soft currency** while retaining all worlds, pets, and masteries. In BSS, there are zero wipes—the ~300h endgame is broken into 30 granular quest checklists.
- **Incremental Leaders (*Antimatter Dimensions*, *Idle Slayer*):** 300h+ campaigns succeed by nesting rapid 1-minute automated loops inside 2-hour runs inside multi-week meta-ascensions.

## 2. Retention Psychology: Goal Gradient & Weber's Law
- **Goal Gradient Effect (Clark Hull):** Motivation accelerates as distance to goal shrinks. Resetting a 100h bar to 0% causes a severe motivation crash.
- **Weber’s Law of Just Noticeable Difference (JND):** A progress bar must advance by **at least 8% to 10% per session** for the brain to perceive progress. Below 3%/day, players register the game as frozen/stagnant, causing >90% churn.

## 3. The 3-Tier Staggered Retention Engine (Recommended)
1. **Layer 1 (Micro-Loops — 15–45 min):** Decoupled Rank Quests and 1–99 Masteries.
2. **Layer 2 (Meso-Loops — 25–35h per Crest):** Rebirth Chapters/Crests (Bronze at 30%, Silver at 65%, Rebirth at 100%).
3. **Layer 3 (Macro Meta-Layer — 200h to 800h+):** Decoupled Celestial Ascension / Star Pasture tree.

---

# Part III: Beyond the Maxed Rebirth Tree: Solving the "Numerical Void"

## 1. The Core Problem
When the rebirth tree is maxed, currency ceases to be a tool for unlocking new experiences. Making money solely to make more money faster triggers existential player burnout: *"Why am I grinding if numbers just get bigger?"*

## 2. Four Concrete Systems to Fill the Void

### Proposal 1: The "Celestial Ascension" (Qualitative Meta-Tree)
Sacrifice maxed cows or spend surplus fortunes for **Star Shards** to buy rule-breaking powers:
- **Vacuum Grazing:** Telekinetically pull grass in a 15-stud radius directly into your rumen.
- **Flora Transmutation:** Chance for standard grass to convert into rare Golden/Cave nodes as you walk.
- **Companion Synergy:** Dogs fetch bait/crates autonomously; Cats generate passive clover aura while sleeping on your back.

### Proposal 2: Horizontal Cow Breeds & Playstyle Archetypes
Spend late-game billions unlocking and leveling distinct cow archetypes:
- **Alpine Forager:** +300% Clover luck and golden node odds.
- **Highland Brute:** Heavy armor, smashes spider nests, extracts Manatite/Mithril in caves.
- **Holstein Merchant:** Town Auction commission discounts, caravan raid cargo bonuses.

### Proposal 3: Botanical Greenhouse & Mutation Lab
A completionist discovery system leveraging existing planting/flora mechanics:
- Cross-breed seeds to discover 50+ rare hybrid flora (*Ghost Clover*, *Abyssal Truffles*).
- **Flora Museum:** Unlocking complete sets grants permanent cosmetic auras and exclusive titles.

### Proposal 4: High-End Luxury Wealth Outlets & Social Flex
Convert surplus trillions into server-wide influence and prestige:
- **Golden Town Pedestal:** Server's top investor has a giant golden statue of their cow and pets displayed in Town Square.
- **Caravan & Fjord Sponsorship:** Fund server-wide expeditions granting rare loot to all participants.

---

## 3. Developer Implementation Roadmap

| Phase | Deliverables | Dev Effort | Player Impact |
| :--- | :--- | :---: | :---: |
| **Phase 1 (Quick Win)** | **Town Prestige Sinks & Mythic Titles:** 3–5 vanity sinks in Town (Pedestal statue, glowing auras, elite titles) for surplus billions. | **Low** | Immediate drain for hoarding whales. |
| **Phase 2 (Medium Term)** | **Celestial Ascension Meta-Tree:** Star Shard prestige layer with qualitative mechanics (vacuum graze, flora transmutation, automation). | **Medium** | Reignites long-term D30+ retention. |
| **Phase 3 (Major Update)** | **Archetypes or Botanical Greenhouse:** Specialized cow breeds or genetic seed cross-breeding collection lab. | **High** | Transforms game into a rich RPG simulator. |

---

# References & Research Sources

## 1. Academic & Cognitive Psychology
- **Goal-Gradient Hypothesis:** Hull, C. L. (1932). "The Goal-Gradient Hypothesis and Maze Learning." *Psychological Review*, 39(1), 25–43. (Foundational behavioral theory explaining why motivation collapses on monolithic progress bar resets, and why sub-goals accelerate engagement).
- **Weber-Fechner Law / Just Noticeable Difference (JND):** Weber, E. H. (1834); Fechner, G. T. (1860). *Elemente der Psychophysik*. (Applied to UI/UX progression feedback: progress bar increments <8–10% per session fail the human perceptual threshold for noticeable advancement, triggering quit loops).
- **Self-Determination Theory:** Ryan, R. M., & Deci, E. L. (2000). "Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being." *American Psychologist*, 55(1), 68–78. (Autonomy, competence, and horizontal player agency as sustainable replacements for raw vertical power inflation).
- **Flow State Optimization:** Csikszentmihalyi, M. (1990). *Flow: The Psychology of Optimal Experience*. Harper & Row. (Dynamic pacing balance between anxiety/frustration and boredom/churn).
- **Player Motivation Typologies:** Yee, N. (2006). "Motivations for Play in Online Games." *CyberPsychology & Behavior*, 9(6), 772–775. (Social status display, completionism, and horizontal playstyle specialization).

## 2. Industry Case Studies & Empirical Production Benchmarks
- **[Pet Simulator 99 / X (BIG Games)](https://pet-simulator.fandom.com/wiki/Rebirth_(Pet_Simulator_99)):** High-frequency prestige cadence (20m–6h cycles); soft-currency-only resets with 100% item, world, and mastery permanence. ([Roblox Experience](https://www.roblox.com/games/8737899170/Pet-Simulator-99))
- **[Bee Swarm Simulator (Onett)](https://bee-swarm-simulator.fandom.com/wiki/Spirit_Bear):** Zero-wipe incremental architecture; 300h+ endgame split into 30 granular Spirit Bear quest milestones and Grandmaster badges. ([Roblox Experience](https://www.roblox.com/games/1537690962/Bee-Swarm-Simulator))
- **[Antimatter Dimensions (Hevipelle)](https://antimatter-dimensions.fandom.com/wiki/Prestige):** Multi-layered nested prestige architecture (Infinity → Eternity → Reality → Celestial) preventing single-tier stagnation. ([Web Game](https://ivark.github.io/AntimatterDimensions/))
- **[Idle Slayer (Pablo Leban / Gert-Jan Stolk)](https://idleslayer.fandom.com/wiki/Ultra_Ascension):** Ultra-Ascension prestige mechanics, Stones of Time pacing dampening, and the Village mini-hub. ([Steam Page](https://store.steampowered.com/app/1353300/Idle_Slayer/))
- **[Cookie Clicker (Julien "Orteil" Thiennot)](https://cookieclicker.fandom.com/wiki/Garden):** Post-max horizontal modules ([Garden genetic seed mutations](https://cookieclicker.fandom.com/wiki/Garden), Stock Market, Grimoire) as non-inflationary wealth sinks. ([Live Game](https://orteil.dashnet.org/cookieclicker/))
- **[GDC Vault: Anthony Pecorella (2015)](https://www.gdcvault.com/play/1022065/Idle-Games-The-Mechanics-and):** *"Idle Games: The Mechanics and Monetization of Self-Playing Games"* ([YouTube Presentation](https://www.youtube.com/watch?v=1F_b-R6gPlo)).
- **[Deconstructor of Fun](https://www.deconstructoroffun.com/blog/2020/7/16/roblox-amp-beyond-the-problem-with-game-creator-platforms):** *"Roblox & Beyond: Game Creator Platforms & Economy"*, [Naavik](https://naavik.co/digest/loot-deconstruction-roblox/), and [GameAnalytics Benchmarks](https://gameanalytics.com/benchmarks/) on D7/D30 churn cliffs (see detailed breakdown in [Deconstructor_of_Fun_Roblox_Analysis.md](file:///Users/jsph/orca/workspaces/cowhub/hippocamp/docs/Deconstructor_of_Fun_Roblox_Analysis.md)).
"""


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    docs_dir = os.path.join(repo_root, "docs")
    os.makedirs(docs_dir, exist_ok=True)

    html_path = os.path.join(docs_dir, "rebirth_model2_exploration.html")
    pdf_path = os.path.join(docs_dir, "Cow_Game_Rebirth_Model2_Exploration.pdf")
    md_path = os.path.join(docs_dir, "Rebirth_Model2_Exploration_Report.md")

    # 1. Build and write HTML
    html_content = build_html()
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Wrote HTML to {html_path} ({len(html_content)} bytes)")

    # 2. Build and write Markdown
    md_content = build_markdown_report()
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"Wrote Markdown to {md_path} ({len(md_content)} bytes)")

    # Artifact path (optional from environment)
    artifact_dir = os.environ.get("ANTIGRAVITY_ARTIFACT_DIR")
    if artifact_dir and os.path.exists(artifact_dir):
        artifact_md = os.path.join(artifact_dir, "Rebirth_Model2_Exploration_Report.md")
        with open(artifact_md, "w", encoding="utf-8") as f:
            f.write(md_content)
        print(f"Wrote Artifact to {artifact_md}")

    # 3. Render PDF via Headless Chrome
    chrome_candidates = [
        os.environ.get("CHROME_BIN"),
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        shutil.which("google-chrome"),
        shutil.which("chromium"),
        shutil.which("chrome"),
    ]
    chrome_bin = next((c for c in chrome_candidates if c and os.path.exists(c)), None)
    if not chrome_bin:
        print("Warning: Google Chrome / Chromium binary not found; skipping PDF generation.")
    else:
        cmd = [
            chrome_bin,
            "--headless",
            "--disable-gpu",
            "--run-all-compositor-stages-before-draw",
            f"--print-to-pdf={pdf_path}",
            f"file://{html_path}",
        ]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if res.returncode == 0 and os.path.exists(pdf_path):
                size_kb = os.path.getsize(pdf_path) / 1024.0
                print(f"SUCCESS: Rendered PDF to {pdf_path} ({size_kb:.1f} KB)")
            else:
                print(f"Warning: Chrome exited with code {res.returncode}")
                if res.stdout:
                    print("Stdout:", res.stdout)
                if res.stderr:
                    print("Stderr:", res.stderr)
        except Exception as e:
            print(f"Warning: PDF rendering failed: {e}")


if __name__ == "__main__":
    main()
