#!/usr/bin/env python3
"""Generate lightweight WAV SFX + loop ambience for co_caro_v2 (project-owned, no external license)."""
import math
import struct
import wave
from pathlib import Path

SR = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        for s in samples:
            v = int(max(-32767, min(32767, s * 32000)))
            w.writeframes(struct.pack("<h", v))


def env_linear(i: int, n: int) -> float:
    if n <= 0:
        return 0.0
    return max(0.0, 1.0 - abs(2.0 * i / n - 1.0)) ** 0.7


def sfx_place() -> list[float]:
    n = int(SR * 0.07)
    out = []
    for i in range(n):
        t = i / SR
        f = 520 + 880 * (i / max(1, n - 1)) ** 0.8
        e = env_linear(i, n)
        click = 0.12 * math.sin(2 * math.pi * 8000 * t) * math.exp(-t * 90)
        body = 0.55 * math.sin(2 * math.pi * f * t)
        out.append(e * body + e * click)
    return out


def sfx_win() -> list[float]:
    notes = [(523.25, 0.11), (659.25, 0.11), (783.99, 0.18)]
    gap = int(SR * 0.03)
    out: list[float] = []
    for freq, dur in notes:
        n = int(SR * dur)
        for i in range(n):
            t = i / SR
            e = math.sin((math.pi * i) / max(1, n - 1)) ** 0.5
            s = e * 0.55 * math.sin(2 * math.pi * freq * t)
            s += e * 0.12 * math.sin(2 * math.pi * freq * 2 * t)
            out.append(s)
        out.extend([0.0] * min(gap, int(SR * 0.05)))
    return out


def sfx_timeout() -> list[float]:
    n = int(SR * 0.38)
    out = []
    for i in range(n):
        t = i / SR
        e = 1.0 - i / n
        f = 180 - 40 * (i / n)
        s = 0.6 * e * math.sin(2 * math.pi * f * t)
        s += 0.08 * e * math.sin(2 * math.pi * (f * 2.3) * t)
        out.append(s)
    return out


def sfx_undo() -> list[float]:
    n = int(SR * 0.09)
    out = []
    for i in range(n):
        t = i / SR
        f = 420 - 220 * (i / max(1, n - 1))
        e = env_linear(i, n)
        out.append(e * 0.5 * math.sin(2 * math.pi * f * t))
    return out


def ambience_loop() -> list[float]:
    period = 441  # 22050 / 441 = 50 Hz fundamental → seamless loop
    loops = int(4.0 * SR / period) + 1
    one: list[float] = []
    for i in range(period):
        ph = 2 * math.pi * i / period
        s = 0.12 * math.sin(ph)
        s += 0.04 * math.sin(2 * ph)
        s += 0.02 * math.sin(3 * ph + 0.7)
        one.append(s)
    full = (one * loops)[: int(4.0 * SR)]
    return full


def main() -> None:
    write_wav(OUT / "sfx_place.wav", sfx_place())
    write_wav(OUT / "sfx_win.wav", sfx_win())
    write_wav(OUT / "sfx_timeout.wav", sfx_timeout())
    write_wav(OUT / "sfx_undo.wav", sfx_undo())
    write_wav(OUT / "ambience_match.wav", ambience_loop())
    print("Wrote:", OUT)


if __name__ == "__main__":
    main()
