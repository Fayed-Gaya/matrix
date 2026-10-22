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
DEST = ROOT / "levels/busboy/assets/refinement"
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
    layers = [(n, Image(w, h)) for n in ["Shadow", "Construction", "Shading", "Detail"]]
    ASSETS[name] = layers
    return [p for n, p in layers]


s, b, h, d = asset("terrain", 128, 64)
for t in range(32):
    x = t % 8 * 16
    y = t // 8 * 16
    if t < 4:
        b.rect(x, y, 16, 16, ["273f3c", "29413d", "2a423d", "283e3d"][t])
        for xx, yy in [(2, 3), (8, 12), (12, 7), (4, 10)]:
            h.line(x + xx, y + yy, x + xx + 2, y + yy, "365248")
            d.dot(x + xx + 1, y + yy - 1, "3f5a4d")
    elif t < 8:
        b.rect(x, y, 16, 16, ["706b60", "746d61", "6e695e", "716a61"][t - 4])
        h.line(x + 3, y + 5, x + 6, y + 5, "858073")
        d.line(x + 9, y + 12, x + 12, y + 12, "5c5b56")
        d.dot(x + 13, y + 3, "93917e")
        d.dot(x + 2, y + 13, "434e45")
    elif t < 12:
        b.rect(x, y, 16, 16, "65534c")
        h.rect(x, y, 16, 1, "3d3a39")
        d.rect(x, y + 1, 16, 1, "8c7157")
        d.line(x + 2, y + 7, x + 7, y + 7, "745e50")
        d.line(x + 10, y + 12, x + 14, y + 12, "514741")
    elif t < 16:
        b.rect(x, y, 16, 16, "393c3d")
        h.rect(x + 1, y + 2, 14, 11, "4b4a46")
        d.line(x + 2, y + 3, x + 13, y + 3, "696156")
        h.rect(x, y + 14, 16, 2, "282f32")
    elif t < 24:
        # Transparent woodland litter: use sparingly over base/path.
        for xx, yy in [(4, 5), (9, 10), (12, 3)]:
            b.ellipse(x + xx, y + yy, 3, 2, "476450")
            d.dot(x + xx, y + yy, "66806a")
    else:
        b.poly(
            [
                (x, y + 9),
                (x + 5, y + 5),
                (x + 11, y + 8),
                (x + 16, y + 3),
                (x + 16, y + 8),
                (x + 11, y + 12),
                (x + 5, y + 9),
                (x, y + 13),
            ],
            "39303f",
        )
        h.line(x, y + 9, x + 5, y + 7, "756078")
        h.line(x + 5, y + 7, x + 11, y + 10, "94758b")
        d.dot(x + 9, y + 9, "b3a5a3")

# Original traveller/waykeeper sheets. Keep the old directional reader contract.
for name, npc in [("traveller", False), ("waykeeper", True)]:
    s, b, h, d = asset(name, 96, 192)
    for row in range(6):
        for frame in range(3):
            x = frame * 32
            y = row * 32
            side = row == 4
            back = row == 5
            bob = 1 if frame == 1 else 0
            dark = "26303b"
            mid = "667374" if npc else "496960"
            light = "9aab9a" if npc else "81987b"
            s.ellipse(x + 6, y + 27, 21, 4, (6, 14, 22, 80))
            b.poly(
                [
                    (x + 10, y + 13 + bob),
                    (x + 23, y + 13 + bob),
                    (x + 26, y + 26),
                    (x + 6, y + 26),
                ],
                dark,
            )
            h.poly(
                [
                    (x + 11, y + 14 + bob),
                    (x + 21, y + 14 + bob),
                    (x + 23, y + 24),
                    (x + 9, y + 24),
                ],
                mid,
            )
            d.line(x + 11, y + 17, x + 9, y + 23, light)
            d.line(x + 19, y + 16, x + 21, y + 23, light)
            b.ellipse(x + 8, y + 3 + bob, 17, 17, dark)
            h.ellipse(x + 9, y + 4 + bob, 15, 14, mid)
            if not back:
                d.rect(
                    x + (17 if side else 12),
                    y + 9 + bob,
                    7 if side else 10,
                    7,
                    "ae9175",
                )
                d.line(
                    x + (18 if side else 13), y + 9 + bob, x + 21, y + 9 + bob, "dec2a0"
                )
                d.dot(x + (22 if side else 15), y + 12 + bob, "29313a")
                if not side:
                    d.dot(x + 20, y + 12 + bob, "29313a")
                if npc:
                    d.rect(x + 14, y + 14 + bob, 8, 3, "b9bca5")
            else:
                d.line(x + 12, y + 7 + bob, x + 19, y + 5 + bob, light)
            b.rect(x + 9, y + 26, 5, 3 + (frame == 0), "51483e")
            b.rect(x + 19, y + 26, 5, 3 + (frame == 2), "51483e")
            d.rect(x + 12, y + 19, 11, 2, "a58a60")
            if npc:
                b.line(x + 28, y + 9, x + 28, y + 29, "7f735a")
                h.line(x + 29, y + 10, x + 29, y + 29, "b9a47a")
                b.rect(x + 25, y + 8, 7, 7, "433b41")
                d.rect(x + 27, y + 10, 3, 4, "e6c583")
            elif not back:
                b.rect(x + 6, y + 17, 5, 7, "6d5547")
                h.line(x + 7, y + 18, x + 7, y + 22, "af8e61")

s, b, h, d = asset("bedroll", 64, 48)
s.ellipse(3, 34, 57, 10, (8, 17, 23, 100))
b.poly([(5, 14), (13, 4), (52, 4), (59, 14), (55, 37), (8, 37)], "302f38")
h.rect(10, 13, 44, 21, "65746a")
h.capsule(11, 5, 42, 13, "8b9280")
d.line(14, 8, 47, 8, "b0ad8c")
d.line(15, 18, 15, 31, "8d967d")
h.rect(11, 33, 43, 3, "45574f")
d.line(47, 17, 50, 30, "3c4a46")

s, b, h, d = asset("table", 64, 64)
s.ellipse(1, 42, 62, 14, (8, 17, 23, 100))
b.poly([(3, 22), (12, 11), (52, 11), (61, 22), (61, 34), (3, 34)], "343339")
h.poly([(6, 21), (14, 13), (50, 13), (58, 21)], "978064")
d.line(6, 24, 57, 24, "b99a70")
b.rect(9, 33, 5, 20, "4e453f")
b.rect(50, 33, 5, 20, "4e453f")
b.poly([(18, 16), (30, 14), (44, 19), (31, 23)], "b8ae8b")
d.line(25, 17, 35, 20, "777561")
b.rect(46, 4, 8, 16, "4a4541")
h.rect(48, 7, 4, 9, "e6bd79")
d.dot(50, 10, "fff0ac")
b.line(7, 9, 4, 38, "8b7657")
d.line(8, 9, 5, 37, "b49b6a")

s, b, h, d = asset("shrine", 64, 80)
s.ellipse(2, 58, 60, 16, (8, 17, 23, 100))
b.poly([(3, 57), (14, 48), (53, 48), (61, 57), (58, 66), (5, 66)], "303b43")
h.poly([(7, 55), (16, 50), (51, 50), (56, 55)], "748582")
d.line(8, 57, 54, 57, "a3aaa0")
b.poly([(19, 51), (15, 14), (22, 5), (43, 5), (49, 14), (45, 51)], "37464c")
h.poly([(22, 48), (19, 15), (24, 8), (40, 8), (45, 15), (41, 48)], "627a78")
d.line(23, 14, 23, 43, "92a39a")
h.line(40, 17, 38, 46, "455d64")
b.ellipse(25, 19, 15, 19, "273c44")
h.poly([(32, 20), (38, 28), (32, 36), (27, 28)], "a3c6ae")
d.line(32, 23, 32, 32, "e0e4be")
d.poly([(16, 58), (21, 53), (23, 58), (20, 60)], "71896c")

s, b, h, d = asset("lantern", 16, 32)
b.line(3, 2, 3, 31, "4f4c47")
h.line(4, 3, 4, 31, "8f805f")
b.line(3, 3, 12, 3, "8f805f")
b.rect(9, 6, 7, 13, "3a363d")
h.rect(11, 8, 3, 8, "d4b16f")
d.rect(12, 10, 2, 4, "fff2b5")

s, b, h, d = asset("fern", 32, 32)
s.ellipse(3, 22, 27, 7, (8, 17, 23, 80))
for x, y in [(3, 13), (8, 7), (16, 5), (24, 8), (29, 15)]:
    b.poly([(16, 26), (x, y), (x + 2, y), (17, 23)], "3c6758")
    h.line(16, 24, x, y, "67846a")
    for yy in range(y + 3, 24, 4):
        d.line(
            x + (16 - x) * (yy - y) / (26 - y),
            yy,
            x + (16 - x) * (yy - y) / (26 - y) + 4,
            yy - 3,
            "789775",
        )

s, b, h, d = asset("fungi", 24, 24)
for x, y in [(5, 11), (14, 7), (19, 14)]:
    b.line(x, y, x, y + 7, "7a8890")
    h.ellipse(x - 4, y - 3, 8, 5, "7aa79b")
    d.line(x - 2, y - 2, x + 1, y - 2, "d3d6ae")

s, b, h, d = asset("glow", 64, 64)
for y in range(64):
    for x in range(64):
        a = max(0, 1 - ((x - 32) ** 2 + (y - 32) ** 2) ** 0.5 / 32) ** 2
        b.dot(x, y, (150, 206, 175, int(a * 85)))


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
