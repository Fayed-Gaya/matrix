"""Original raster construction studies; Aseprite layers are the editable masters.
Run explicitly with --reseed to replace these initial studies, never on save/build.
No map generation, network, third-party inputs, or runtime dependency.
"""

import argparse
import math
import os
from pathlib import Path
import struct
import subprocess
import tempfile
import zlib

ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path(__file__).resolve().parent
DEST = ROOT / "levels/bubby/assets/refinement"
# Shared warm metal ramp, blue shadows, oxidised teal, amber and desaturated wood.
P = [
    "101d27",
    "1b2c36",
    "293c43",
    "3b5053",
    "536768",
    "71817a",
    "939b88",
    "b1b49a",
    "d1c5a0",
    "e6d3a4",
    "33484b",
    "45635f",
    "618379",
    "8eb6a0",
    "c2d8ae",
    "705d4e",
    "927656",
    "b29466",
    "d4ae70",
    "f0cb87",
    "15273a",
    "1e354a",
    "345269",
    "658591",
]


def rgba(c):
    return tuple(bytes.fromhex(P[c] if isinstance(c, int) else c)) + (255,)


class Image:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.data = bytearray(w * h * 4)

    def dot(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.data[(y * self.w + x) * 4 : (y * self.w + x) * 4 + 4] = bytes(
                rgba(c) if isinstance(c, (str, int)) else c
            )

    def rect(self, x, y, w, h, c):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.dot(xx, yy, c)

    def line(self, x, y, xx, yy, c):
        n = max(abs(xx - x), abs(yy - y), 1)
        for i in range(int(n) + 1):
            self.dot(round(x + (xx - x) * i / n), round(y + (yy - y) * i / n), c)

    def poly(self, points, c):
        for y in range(
            max(0, min(p[1] for p in points)),
            min(self.h, max(p[1] for p in points) + 1),
        ):
            xs = []
            for (x1, y1), (x2, y2) in zip(points, points[1:] + points[:1]):
                if (y1 <= y < y2) or (y2 <= y < y1):
                    xs.append(x1 + (y - y1) * (x2 - x1) / (y2 - y1))
            xs.sort()
            for a, b in zip(xs[::2], xs[1::2]):
                self.rect(math.ceil(a), y, math.floor(b) - math.ceil(a) + 1, 1, c)

    def ellipse(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if ((xx + 0.5 - x - w / 2) / (w / 2)) ** 2 + (
                    (yy + 0.5 - y - h / 2) / (h / 2)
                ) ** 2 <= 1:
                    self.dot(xx, yy, c)

    def capsule(self, x, y, w, h, c):
        r = min(w // 2, 12)
        self.rect(x, y + r, w, h - 2 * r, c)
        self.ellipse(x, y, w, r * 2, c)
        self.ellipse(x, y + h - r * 2, w, r * 2, c)

    def bolts(self, points):
        for x, y in points:
            self.rect(x, y, 2, 2, 2)
            self.dot(x, y, 7)

    def vents(self, x, y, n, w=10):
        for i in range(n):
            self.line(x, y + i * 3, x + w, y + i * 3, 1)
            self.line(x, y + i * 3 + 1, x + w, y + i * 3 + 1, 4)

    def png(self, path):
        def chunk(t, d):
            return (
                struct.pack(">I", len(d))
                + t
                + d
                + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
            )

        rows = b"".join(
            b"\0" + self.data[y * self.w * 4 : (y + 1) * self.w * 4]
            for y in range(self.h)
        )
        path.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows))
            + chunk(b"IEND", b"")
        )


ASSETS = {}


def asset(name, w, h):
    layers = [(n, Image(w, h)) for n in ["Shadow", "Form", "Shade", "Finish"]]
    ASSETS[name] = layers
    return [p for n, p in layers]


# Warm plaster, honey timber and lavender-grey stone; deliberately not ship metal.
s, b, h, d = asset("room-atlas", 128, 128)
for t in range(16):
    x = (t % 4) * 32
    y = (t // 4) * 32
    if t < 4:
        b.rect(x, y, 32, 32, ["b58b76", "b38a75", "b9917b", "b28a77"][t])
        for yy in [0, 16]:
            h.line(x, y + yy, x + 31, y + yy, "987361")
            h.line(x, y + yy + 1, x + 31, y + yy + 1, "c6a18a")
        d.line(x + (t * 7) % 26, y + 2, x + (t * 7) % 26, y + 15, "a47e6a")
        d.line(x + 3, y + 8, x + 11, y + 8, "bd9880")
        d.line(x + 17, y + 25, x + 28, y + 25, "a77f6b")
    elif t < 8:
        b.rect(x, y, 32, 32, ["b2aaa0", "ada69e", "b7afa3", "afa79f"][t - 4])
        h.rect(x, y, 32, 1, "8e8990")
        h.rect(x, y, 1, 32, "9b9495")
        d.line(x + 3, y + 3, x + 27, y + 3, "c0b9ac")
        d.line(x + 6, y + 23, x + 13, y + 23, "a49da0")
    elif t < 12:
        b.rect(x, y, 32, 32, "ddcbb5")
        h.rect(x, y + 26, 32, 6, "8e7574")
        d.line(x, y + 25, x + 31, y + 25, "f1ddbe")
        d.dot(x + 9, y + 10, "d4c0af")
        d.line(x + 20, y + 16, x + 24, y + 16, "d6c3af")
    else:
        b.rect(x, y, 32, 32, "594958")
        h.rect(x + 3, y, 26, 32, "796170")
        d.line(x + 4, y, x + 4, y + 31, "a37d83")

s, b, h, d = asset("sofa", 112, 72)
s.ellipse(5, 49, 105, 22, (48, 38, 53, 75))
b.poly([(7, 32), (12, 12), (100, 12), (106, 32), (106, 57), (7, 57)], "56556a")
b.rect(15, 12, 84, 35, "81908b")
h.rect(17, 14, 80, 3, "b4b6a2")
h.line(55, 18, 55, 43, "657873")
h.rect(16, 38, 82, 12, "a0ab98")
b.capsule(5, 31, 14, 27, "647e77")
b.capsule(97, 31, 13, 27, "647e77")
d.line(8, 34, 8, 51, "9caf9a")
d.line(100, 34, 100, 51, "9caf9a")
h.rect(20, 50, 75, 6, "6d827b")
d.rect(17, 57, 6, 6, "61525b")
d.rect(92, 57, 6, 6, "61525b")
b.poly([(22, 23), (37, 20), (43, 36), (26, 39)], "d5ac91")
h.line(25, 25, 35, 23, "ecd0ad")
b.poly([(73, 23), (89, 25), (86, 40), (72, 37)], "b7a1b4")
d.line(76, 28, 85, 29, "d8bec4")
# A loose folded throw on the arm, no personal significance asserted.
b.rect(6, 38, 15, 19, "c49f8c")
h.line(9, 41, 9, 55, "e1bea0")
d.line(15, 41, 15, 59, "ac847b")

s, b, h, d = asset("bed", 72, 104)
s.ellipse(1, 85, 70, 16, (48, 38, 53, 65))
b.rect(5, 13, 62, 78, "73595b")
b.poly([(8, 15), (12, 4), (62, 4), (65, 15), (65, 84), (8, 84)], "a98478")
h.line(12, 6, 61, 6, "d8b39b")
b.rect(12, 20, 49, 65, "e5d2b8")
b.capsule(15, 13, 42, 19, "f4e3c8")
h.line(19, 25, 51, 25, "cbb99f")
b.rect(12, 37, 49, 45, "a3a7af")
h.rect(12, 37, 49, 5, "c2c5c1")
h.rect(17, 45, 2, 31, "b5b6ba")
h.rect(51, 46, 3, 30, "8d94a2")
d.line(14, 79, 58, 79, "7b8193")
d.rect(8, 85, 5, 10, "604d55")
d.rect(59, 85, 5, 10, "604d55")

s, b, h, d = asset("kitchen", 144, 72)
s.rect(4, 57, 136, 9, (48, 38, 53, 65))
b.rect(3, 22, 137, 35, "7b6970")
b.rect(6, 29, 131, 28, "a8b4a2")
h.rect(6, 30, 131, 2, "cbd0b4")
for x in [8, 42, 77, 111]:
    h.rect(x, 34, 25, 19, "91a191")
    d.line(x + 4, 38, x + 20, 38, "71877e")
    d.rect(x + 17, 36, 4, 2, "e9d7b6")
b.poly([(3, 22), (9, 14), (135, 14), (140, 22)], "e7d8bd")
h.rect(3, 23, 137, 4, "bbab98")
b.ellipse(18, 16, 34, 8, "8c9392")
h.ellipse(21, 16, 28, 6, "b4c0b8")
d.line(40, 16, 40, 6, "667e82")
d.line(40, 6, 30, 6, "667e82")
b.rect(80, 15, 40, 9, "5b5c68")
for x in [84, 104]:
    d.ellipse(x, 16, 10, 5, "91918e")
    d.ellipse(x + 2, 17, 6, 3, "525967")
b.capsule(60, 6, 12, 12, "c59e78")
d.line(63, 8, 68, 8, "f2d4a3")

s, b, h, d = asset("desk", 80, 64)
s.ellipse(1, 43, 78, 16, (48, 38, 53, 65))
b.poly([(4, 24), (12, 12), (70, 12), (77, 24), (77, 37), (4, 37)], "795d62")
h.poly([(6, 24), (13, 14), (69, 14), (75, 24)], "cfaa89")
d.line(9, 24, 72, 24, "e9c59f")
b.rect(10, 36, 6, 17, "8c6d68")
b.rect(64, 36, 6, 17, "8c6d68")
b.poly([(26, 16), (42, 14), (53, 21), (38, 24)], "f1dfbd")
d.line(38, 17, 39, 22, "c7b091")
d.line(29, 19, 35, 18, "a58a7b")
d.line(43, 18, 47, 20, "a58a7b")
b.ellipse(59, 15, 10, 6, "ece1c7")
h.rect(60, 18, 8, 5, "d4c6b3")
d.line(68, 18, 71, 19, "f2e9d5")
b.capsule(30, 37, 21, 18, "879788")
h.line(33, 40, 47, 40, "b9c1a3")
d.rect(33, 54, 3, 8, "715e63")
d.rect(46, 54, 3, 8, "715e63")

s, b, h, d = asset("doors", 80, 96)
s.rect(0, 78, 80, 12, (48, 38, 53, 60))
b.rect(2, 1, 75, 84, "6f5b64")
h.rect(5, 3, 69, 79, "f0d3b2")
b.rect(10, 8, 57, 65, "8faeb4")
h.rect(12, 10, 25, 59, "acc1bd")
h.rect(41, 10, 24, 59, "9cb6b6")
d.poly([(14, 12), (28, 12), (14, 35)], "cad3c8")
d.poly([(44, 31), (62, 13), (62, 22), (44, 42)], "b9c9c1")
b.rect(36, 6, 5, 73, "e2c8a6")
b.rect(9, 46, 59, 3, "dfc9ae")
d.rect(31, 48, 3, 7, "796d71")
b.rect(7, 73, 64, 9, "aa8e80")
d.line(9, 75, 67, 75, "dbc1a4")
# Loose sage curtains with dark inner folds.
b.poly([(0, 0), (12, 0), (10, 45), (4, 59), (0, 59)], "758d87")
h.line(3, 4, 3, 48, "a1b1a0")
b.poly([(67, 0), (79, 0), (79, 59), (73, 59), (69, 45)], "758d87")
h.line(75, 4, 75, 48, "a1b1a0")

s, b, h, d = asset("window", 112, 64)
b.rect(6, 4, 100, 53, "715b65")
h.rect(9, 6, 94, 48, "efd6b5")
b.rect(14, 10, 84, 37, "9fb8b9")
h.poly([(15, 12), (97, 12), (97, 33), (15, 27)], "c6cfc4")
h.rect(52, 10, 5, 39, "e5ceb1")
h.rect(13, 29, 86, 3, "e5ceb1")
d.rect(3, 51, 106, 7, "b2917e")
d.line(4, 52, 107, 52, "f0d2ab")
b.poly([(1, 1), (19, 1), (16, 26), (7, 44), (1, 44)], "b599a4")
h.line(5, 4, 5, 36, "d9bbc0")
b.poly([(94, 1), (110, 1), (110, 44), (102, 44), (96, 26)], "b599a4")
h.line(106, 4, 106, 36, "d9bbc0")

s, b, h, d = asset("planter", 40, 56)
s.ellipse(2, 43, 36, 10, (48, 38, 53, 65))
b.poly([(5, 31), (35, 31), (31, 49), (10, 49)], "ad7772")
h.rect(4, 29, 32, 6, "d2a38b")
d.line(12, 37, 14, 45, "d1a089")
for x, y in [(14, 20), (23, 17), (30, 26), (10, 29), (20, 29)]:
    b.line(20, 32, x, y - 5, "687e72")
    b.ellipse(x - 5, y - 5, 10, 7, "859981")
    h.line(x - 3, y - 3, x + 2, y - 3, "b1bb94")
    b.ellipse(x - 2, y - 12, 5, 9, "a79aae")
    d.dot(x, y - 10, "e0c7d5")

s, b, h, d = asset("rail", 32, 48)
b.rect(2, 5, 5, 43, "625d70")
h.rect(3, 6, 1, 40, "a5a0a2")
b.rect(23, 5, 5, 43, "625d70")
h.rect(24, 6, 1, 40, "a5a0a2")
b.rect(0, 0, 32, 8, "746b7b")
h.rect(0, 0, 32, 3, "bbb1a8")
d.rect(0, 36, 32, 4, "7b7381")

s, b, h, d = asset("rug", 144, 80)
b.poly([(7, 2), (136, 2), (142, 75), (2, 75)], "9b8791")
h.rect(10, 6, 125, 64, "c3a6a0")
h.rect(14, 10, 117, 56, "a88e95")
d.rect(18, 14, 109, 48, "b99e9d")
for x in range(8, 139, 6):
    d.line(x, 76, x, 79, "d9bcb0")
for x in range(28, 124, 24):
    d.poly([(x, 34), (x + 7, 28), (x + 14, 34), (x + 7, 40)], "c8aca5")

s, b, h, d = asset("skyline", 640, 112)
for y in range(112):
    c = "c7c1c3" if y < 35 else ("d8c9be" if y < 75 else "b5adb5")
    b.rect(0, y, 640, 1, c)
for x, y, w, hh in [
    (12, 60, 70, 52),
    (98, 43, 49, 69),
    (169, 68, 68, 44),
    (253, 51, 58, 61),
    (332, 65, 94, 47),
    (451, 37, 53, 75),
    (529, 56, 96, 56),
]:
    h.rect(x, y, w, hh, "a4a3ae")
    h.rect(x + 3, y + 3, w - 6, hh - 3, "b4adb5")
    d.rect(x - 3, y, w + 6, 3, "9693a1")
    for xx in range(x + 9, x + w - 5, 13):
        for yy in range(y + 10, 110, 16):
            d.rect(xx, yy, 5, 7, "cebdad")
    d.rect(x + w - 14, y - 8, 9, 8, "aba3ad")
h.ellipse(493, 14, 19, 19, "f3dfc0")
h.line(42, 26, 108, 26, "ded1c8")
h.line(320, 16, 365, 16, "ded1c8")

s, b, h, d = asset("mess", 32, 32)
s.ellipse(2, 17, 28, 10, (74, 62, 72, 45))
b.ellipse(5, 16, 20, 8, "c7c2b0")
h.ellipse(9, 17, 11, 4, "eee1bd")
b.poly([(19, 4), (25, 1), (27, 4), (22, 13), (18, 16)], "b1aebb")
d.line(19, 14, 25, 4, "e0d4cb")


# Layered Aseprite masters. Avoid changing user preferences or existing masters silently.
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reseed", action="store_true")
    args = parser.parse_args()
    SOURCE.mkdir(exist_ok=True)
    DEST.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="matrix-raster-") as tmp:
        temp = Path(tmp)
        lua = []
        for name, layers in ASSETS.items():
            target = SOURCE / (name + ".aseprite")
            if target.exists() and not args.reseed:
                raise SystemExit(
                    "Refusing to overwrite editable master: " + str(target)
                )
            w, h = layers[0][1].w, layers[0][1].h
            lua.append(
                f'local s=Sprite({w},{h},ColorMode.RGB); s.layers[1].name="Shadow"'
            )
            for i, (label, image) in enumerate(layers):
                path = temp / (name + "-" + label + ".png")
                image.png(path)
                lua.append(
                    "local imported=app.open("
                    + repr(str(path))
                    + "); local pixels=imported.cels[1].image:clone(); imported:close()"
                )
                lua.append(
                    "app.sprite=s; local layer="
                    + ("s.layers[1]" if i == 0 else "s:newLayer()")
                    + "; layer.name="
                    + repr(label)
                )
                lua.append("s:newCel(layer,1,pixels,Point(0,0))")
            lua.append("s:saveAs(" + repr(str(target)) + "); s:close()")
        code = temp / "seed.lua"
        code.write_text("\n".join(lua))
        run = subprocess.run(
            [
                "/Applications/Aseprite.app/Contents/MacOS/aseprite",
                "--batch",
                "--script",
                str(code),
            ],
            env={**os.environ, "ASEPRITE_USER_FOLDER": tmp},
            capture_output=True,
            text=True,
        )
        if run.returncode:
            raise SystemExit(run.stdout + run.stderr)
    for name in ASSETS:
        subprocess.run(
            [
                "python3",
                str(ROOT / "scripts/export_art.py"),
                "--source",
                str(SOURCE / (name + ".aseprite")),
                "--output",
                str(DEST / (name + ".png")),
            ],
            check=True,
        )


if __name__ == "__main__":
    main()
