#!/usr/bin/env python3
"""Summarise a Roblox MicroProfiler capture (.gprx or .x.html) with LibMP.

Prints the slowest frames and, for each, the scopes that took the most time on the main thread; then the scopes
with the highest average time over all frames.

Setup (once): put LibMP.py from https://github.com/Roblox/libmp/releases next to this script or on PYTHONPATH, and
install its dependency:  python3 -m pip install "wasmtime>=20.0.0,<50.0.0"
Run:  python3 scripts/mp_analyze.py ~/Library/Logs/Roblox/microprofile-<time>.gprx [--top 5] [--depth 4]
"""

import argparse
import collections
import sys

import LibMP


def text(value):
    return value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)


def field(obj, *names):
    for name in names:
        if hasattr(obj, name):
            return getattr(obj, name)
        if isinstance(obj, dict) and name in obj:
            return obj[name]
    raise AttributeError(names[0])


def scope_times(session, iterator, state, tick_ms, frame_a, frame_b, max_depth, names):
    """Inclusive ms per timer for scopes at depth <= max_depth, over frames frame_a..frame_b."""
    totals = collections.Counter()
    iterator.RewindTo(frame_a, frame_b)
    while iterator.Step():
        if not state.IsExit() or state.ThreadStackIsUnderflowed():
            continue
        depth = state.ThreadStackDepth()
        if depth > max_depth:
            continue
        element = iterator.GetCurrentThreadStackElement(depth)
        if not element:
            continue
        ms = (state.Timestamp() - element.EnterTimestamp()) * tick_ms
        timer_id = state.TimerId()
        if timer_id not in names:
            desc = session.FetchTimerDesc(timer_id)
            names[timer_id] = text(field(desc, "timerName", "TimerName")) if desc else f"<timer {timer_id}>"
        totals[(depth, names[timer_id])] += ms
    return totals


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("capture")
    parser.add_argument("--top", type=int, default=5, help="slowest frames to break down")
    parser.add_argument("--depth", type=int, default=4, help="deepest scope level to report")
    args = parser.parse_args()

    with LibMP.create() as libmp:
        session = libmp.Session.OpenFromFile(args.capture)
        if session is None or not session.IsValid():
            sys.exit("could not open capture")
        with session:
            gdesc = session.FetchGlobalDesc()
            tick_ms = field(gdesc, "tickToMsCpu", "TickToMsCpu")
            first, last = session.GetFrameIdMin(), session.GetFrameIdMax()
            main_thread = session.FindThreadId("*rbx main*") or session.FindThreadId("*main*")
            if not main_thread:
                sys.exit("no main thread in capture")

            frames = []
            for fid in range(first, last + 1):
                fd = session.FetchFrameDesc(fid)
                if not fd:
                    continue
                start = field(fd, "tickStartCpu", "TickStartCpu")
                end = field(fd, "tickEndCpu", "TickEndCpu")
                frames.append((fid, (end - start) * tick_ms))
            if not frames:
                sys.exit("no frames")
            ms = sorted(f[1] for f in frames)
            print(f"frames {len(frames)}  median {ms[len(ms) // 2]:.2f} ms  p95 {ms[int(len(ms) * 0.95)]:.2f} ms  "
                  f"max {ms[-1]:.2f} ms")

            names = {}
            with session.CreateLogIterator() as iterator:
                iterator.Configure({"ThreadIds": [main_thread]})
                state = iterator.GetState()

                for fid, frame_ms in sorted(frames, key=lambda f: -f[1])[: args.top]:
                    print(f"\n== frame {fid}: {frame_ms:.2f} ms (main thread scopes, inclusive)")
                    totals = scope_times(session, iterator, state, tick_ms, fid, fid, args.depth, names)
                    for (depth, name), t in totals.most_common(15):
                        print(f"  {t:8.2f} ms  {'  ' * depth}{name}")

                print(f"\n== average per frame over all {len(frames)} frames (depth <= {args.depth})")
                totals = scope_times(session, iterator, state, tick_ms, first, last, args.depth, names)
                for (depth, name), t in totals.most_common(25):
                    print(f"  {t / len(frames):8.3f} ms  {'  ' * depth}{name}")


if __name__ == "__main__":
    main()
