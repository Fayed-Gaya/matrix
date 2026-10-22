"""Original raster construction studies; Aseprite layers are the editable masters.
Run explicitly with --reseed to replace these initial studies, never on save/build.
No map generation, network, third-party inputs, or runtime dependency.
"""

import argparse
import math
import os
from pathlib import Path
import random
import struct
import subprocess
import tempfile
import zlib

ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path(__file__).resolve().parent
DEST = ROOT / "hub/assets/round2"
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


# Wide staggered deck modules with long grain and sparse wear, not a checkerboard.
s, b, h, d = asset("deck-atlas", 256, 128)
rng = random.Random(72)
for tile in range(16):
    ox = (tile % 8) * 32
    oy = (tile // 8) * 32
    b.rect(ox, oy, 32, 32, 3 if tile < 8 else 2)
    if tile < 8:
        # Half of each 64px-wide panel; seams only at the panel ends.
        base = rgba(3)
        b.rect(ox, oy, 32, 32, "50564f" if tile < 4 else "4a514c")
        h.rect(ox, oy + 1, 32, 1, "596057")
        h.rect(ox, oy + 31, 32, 1, "3e4946")
        if tile % 2 == 0:
            h.rect(ox, oy, 1, 32, "2a3a3e")
            d.bolts([(ox + 3, oy + 4), (ox + 3, oy + 25)])
        for j in range(9):
            x = rng.randrange(3, 29)
            y = rng.randrange(5, 25)
            d.line(
                ox + x,
                oy + y,
                ox + min(30, x + rng.randrange(1, 4)),
                oy + y,
                "535b52" if j % 2 else "46504a",
            )
    elif tile in [8, 9, 10, 11]:
        # Upper and lower hull courses, continuous seams, bevels and inset panels.
        b.rect(ox, oy, 32, 32, 2)
        b.rect(ox, oy + 2, 32, 23, 5)
        h.rect(ox, oy + 3, 32, 2, 7)
        h.rect(ox, oy + 6, 32, 16, 4)
        h.rect(ox + 2, oy + 7, 28, 13, 5)
        h.rect(ox, oy + 24, 32, 3, 1)
        h.rect(ox, oy + 27, 32, 1, 16)
        h.rect(ox, oy + 28, 32, 4, 2)
        if tile == 10:
            d.vents(ox + 5, oy + 10, 3, 20)
        else:
            d.line(ox + 4, oy + 10, ox + 26, oy + 10, 6)
            d.bolts([(ox + 2, oy + 6), (ox + 28, oy + 19)])
    else:
        # Side bulkhead and front cutaway. Thick ribs with bevel and warm footlight.
        b.rect(ox, oy, 32, 32, 0)
        if tile < 14:
            b.poly(
                [(ox + 3, oy), (ox + 24, oy), (ox + 28, oy + 31), (ox + 6, oy + 31)], 3
            )
            h.rect(ox + 7, oy, 3, 32, 6)
            h.rect(ox + 11, oy, 9, 32, 4)
            h.rect(ox + 21, oy, 3, 32, 2)
            d.bolts([(ox + 12, oy + 6), (ox + 15, oy + 25)])
            if tile == 13:
                d.rect(ox + 24, oy + 8, 2, 16, 17)
        else:
            b.rect(ox, oy, 32, 8, 4)
            h.rect(ox, oy, 32, 2, 6)
            h.rect(ox, oy + 7, 32, 3, 2)
            b.rect(ox, oy + 10, 32, 13, 1)
            h.rect(ox, oy + 11, 32, 1, 3)
            h.rect(ox, oy + 23, 32, 9, 0)
            if tile == 15:
                d.vents(ox + 4, oy + 13, 3, 22)
# Fill unused atlas area with transparent pixels; sixteen cells are authoritative.

# Chamber pair shares a recessed mounting/service bay, distinct from the pods.
s, b, h, d = asset("chamber-bay", 208, 144)
s.poly([(6, 5), (202, 5), (208, 139), (16, 144), (0, 133)], (5, 13, 20, 110))
b.poly(
    [(10, 0), (194, 0), (200, 8), (200, 128), (190, 136), (10, 136), (2, 128), (2, 8)],
    2,
)
h.poly(
    [(10, 2), (192, 2), (196, 8), (196, 126), (188, 131), (10, 131), (6, 126), (6, 8)],
    3,
)
h.rect(10, 14, 180, 111, 1)
for x in [14, 110]:
    h.rect(x, 20, 78, 101, 2)
    h.line(x, 20, x + 77, 20, 4)
    d.vents(x + 21, 124, 2, 32)
    d.bolts([(x + 3, 23), (x + 71, 23), (x + 3, 115), (x + 71, 115)])
# Service headers, insulated leads and central housing.
for y in [5, 9]:
    d.line(18, y, 184, y, 5 if y == 5 else 16)
d.rect(92, 28, 14, 76, 0)
d.rect(94, 30, 10, 72, 4)
d.vents(95, 34, 8, 6)
d.rect(94, 66, 10, 23, 2)
for y in range(70, 87, 4):
    d.rect(96, y, 3, 1, 13)
d.rect(97, 94, 3, 4, 18)
for x in [6, 196]:
    d.line(x, 19, x, 118, 5)
    d.line(x + 1, 19, x + 1, 118, 1)

for sealed in (False, True):
    s, b, h, d = asset("pod-sealed" if sealed else "pod-open", 80, 112)
    s.ellipse(3, 90, 76, 19, (4, 14, 22, 135))
    s.rect(10, 29, 66, 70, (4, 14, 22, 90))
    b.capsule(6, 9, 64, 94, 0)
    b.capsule(7, 7, 62, 94, 4)
    b.capsule(9, 5, 58, 94, 6)
    # Per-pixel cylindrical housing, lit from upper left. Restrained 7-colour ramp.
    for y in range(10, 94):
        inset = (
            max(0, int(7 - math.sqrt(max(0, 49 - (max(0, 14 - y, y - 88)) ** 2))))
            if y < 14 or y > 88
            else 0
        )
        for x in range(10 + inset, 66 - inset):
            ramp = [4, 5, 7, 8, 7, 6, 5, 4, 3]
            h.dot(x, y, ramp[min(8, int((x - 10) / 56 * 9))])
    h.capsule(17, 16, 43, 71, 1)
    h.capsule(20, 19, 37, 65, 2)
    if sealed:
        # Opaque reinforced cover: continuous metal, no glass/body outline.
        h.capsule(21, 20, 35, 64, 10)
        for x, c in [(23, 4), (25, 5), (28, 6), (31, 5), (39, 4), (47, 3), (52, 2)]:
            h.rect(x, 27, 3 if x != 31 else 8, 51, c)
        for y in [31, 69]:
            d.poly(
                [(19, y), (55, y), (58, y + 3), (56, y + 7), (21, y + 7), (18, y + 4)],
                2,
            )
            d.line(21, y + 1, 54, y + 1, 7)
            d.line(22, y + 3, 54, y + 3, 5)
        d.rect(32, 47, 13, 8, 1)
        d.rect(34, 49, 9, 3, 11)
        d.rect(34, 49, 2, 1, 13)
    else:
        # One continuous flat ribbed mattress: no head/torso-shaped cushions.
        h.capsule(22, 23, 32, 58, 0)
        h.capsule(25, 27, 26, 49, 10)
        h.rect(27, 30, 22, 42, 11)
        for y in range(32, 73, 5):
            d.line(28, y, 47, y, 12)
            d.line(28, y + 1, 47, y + 1, 10)
        d.line(26, 75, 49, 75, 5)
        # Raised lid projects above the head on a pair of mechanical hinges.
        h.poly(
            [
                (12, 3),
                (21, 0),
                (57, 0),
                (65, 5),
                (61, 18),
                (55, 21),
                (18, 21),
                (10, 16),
            ],
            1,
        )
        h.poly([(15, 4), (22, 2), (55, 2), (61, 6), (58, 14), (18, 14), (13, 11)], 5)
        d.line(20, 4, 54, 4, 8)
        d.line(17, 12, 56, 12, 3)
        for x in [13, 59]:
            d.rect(x, 16, 3, 11, 7)
            d.rect(x, 20, 3, 3, 3)
    # Lower access casing, vents, locking dogs, status strip and hardware.
    h.poly([(9, 87), (65, 87), (69, 94), (64, 103), (15, 105), (7, 98)], 2)
    h.poly([(10, 88), (64, 88), (65, 96), (59, 99), (16, 100), (9, 97)], 5)
    d.vents(14, 91, 2, 10)
    d.vents(48, 91, 2, 10)
    d.rect(30, 89, 13, 7, 1)
    d.rect(32, 90, 9, 2, 12)
    d.rect(32, 90, 3, 1, 14)
    for x in [5, 65]:
        for y in [35, 74]:
            d.rect(x, y, 6, 9, 1)
            d.rect(x, y, 4, 7, 6)
            d.rect(x + 1, y + 1, 2, 3, 8)
    for x in [17, 55]:
        d.rect(x, 101, 8, 5, 1)
        d.line(x, 102, x + 5, 102, 4)
    d.bolts([(14, 24), (59, 24), (12, 84), (61, 84)])
    if sealed:
        d.rect(35, 97, 2, 1, 14)
        d.rect(39, 97, 2, 1, 13)

s, b, h, d = asset("viewport", 192, 64)
s.poly(
    [(7, 6), (187, 6), (192, 14), (192, 57), (185, 64), (8, 64), (0, 55), (0, 14)], 0
)
b.poly([(8, 0), (181, 0), (188, 7), (188, 51), (180, 58), (9, 58), (2, 51), (2, 8)], 4)
h.poly(
    [(10, 2), (179, 2), (184, 7), (184, 48), (178, 53), (11, 53), (6, 48), (6, 8)], 7
)
h.poly(
    [(15, 6), (176, 6), (180, 10), (180, 45), (175, 49), (15, 49), (10, 44), (10, 11)],
    2,
)
h.poly(
    [
        (18, 10),
        (173, 10),
        (176, 13),
        (176, 41),
        (171, 45),
        (18, 45),
        (14, 41),
        (14, 14),
    ],
    20,
)
# Deep space has cool depth and a very faint scattering of stars, not an event.
for y in range(13, 44):
    for x in range(18, 173):
        if y > 36 and rng.random() < max(0, 0.16 - abs(x - 130) / 700):
            h.dot(x, y, "182c3f")
for x, y, c in [
    (24, 21, 7),
    (43, 34, 23),
    (64, 18, 6),
    (98, 39, 6),
    (131, 26, 8),
    (150, 17, 23),
    (165, 37, 6),
    (81, 29, 22),
    (113, 16, 22),
]:
    d.dot(x, y, c)
d.line(130, 26, 132, 26, 8)
d.line(131, 25, 131, 27, 8)
d.line(20, 12, 119, 12, 21)
d.line(20, 13, 20, 36, 21)
for x in [9, 180]:
    d.bolts([(x, 7), (x, 47)])
d.line(18, 51, 172, 51, 8)
d.line(20, 52, 169, 52, 16)
for x in [25, 154]:
    d.vents(x, 55, 2, 13)
# Hull reinforcement flange above/below frame.
d.line(13, 1, 177, 1, 6)
d.line(18, 61, 175, 61, 2)

s, b, h, d = asset("terminal", 64, 80)
s.ellipse(2, 61, 61, 15, (4, 13, 20, 140))
# Compact wooden/composite desktop and supports, softened material, angular form.
b.poly([(4, 47), (54, 47), (62, 58), (59, 65), (5, 65), (1, 59)], 1)
h.poly([(6, 47), (53, 47), (59, 57), (4, 57)], 16)
h.line(5, 48, 51, 48, 18)
h.rect(5, 58, 54, 5, 15)
h.line(6, 58, 57, 58, 17)
for x in [8, 48]:
    b.poly([(x, 62), (x + 8, 62), (x + 7, 77), (x + 2, 77)], 2)
    h.line(x + 2, 64, x + 2, 73, 4)
# Chamfered CRT with three dimensional side casing.
b.poly([(13, 5), (44, 3), (51, 9), (51, 37), (44, 43), (12, 40), (9, 34), (9, 11)], 1)
h.poly([(14, 5), (43, 5), (47, 9), (47, 35), (42, 39), (13, 37), (11, 32), (11, 11)], 6)
h.line(15, 6, 42, 6, 8)
h.poly([(45, 8), (49, 11), (49, 34), (45, 37)], 3)
h.poly(
    [(17, 10), (39, 10), (43, 14), (43, 30), (39, 34), (17, 33), (14, 29), (14, 15)], 2
)
h.poly(
    [(18, 12), (38, 12), (41, 15), (41, 28), (38, 31), (18, 30), (16, 27), (16, 16)], 0
)
h.rect(19, 15, 19, 12, 11)
h.rect(20, 16, 17, 10, "1b453e")
for x, y, w, hh in [
    (22, 17, 2, 8),
    (34, 17, 2, 8),
    (24, 18, 2, 2),
    (26, 20, 2, 2),
    (28, 22, 2, 2),
    (30, 20, 2, 2),
    (32, 18, 2, 2),
]:
    d.rect(x, y, w, hh, 13)
d.line(20, 13, 36, 13, 12)
d.rect(37, 35, 3, 1, 13)
d.rect(15, 35, 7, 1, 4)
h.rect(25, 40, 10, 6, 3)
h.poly([(20, 45), (40, 45), (43, 48), (18, 48)], 4)
# Individual key clusters, cable grommet and drawer latch.
h.poly([(13, 50), (46, 50), (51, 56), (10, 56)], 2)
for y in [51, 53]:
    for x in range(15, 45, 4):
        d.rect(x, y, 3, 1, 6)
d.line(19, 55, 37, 55, 7)
d.rect(53, 50, 3, 2, 3)

s, b, h, d = asset("worktable", 80, 80)
s.ellipse(2, 57, 76, 18, (5, 14, 20, 110))
b.poly([(8, 22), (64, 22), (76, 36), (76, 45), (5, 45), (2, 38)], 1)
h.poly([(9, 22), (63, 22), (73, 35), (5, 35)], 16)
h.line(10, 23, 61, 23, 18)
for y in [26, 30, 33]:
    d.line(14, y, 57, y, 17)
h.rect(5, 36, 69, 7, 15)
h.line(5, 36, 73, 36, 17)
for x in [10, 62]:
    b.rect(x, 44, 6, 18, 2)
    h.line(x, 44, x, 58, 4)
# Closed journal, plain pencil, cup. No real personal references or text.
h.poly([(18, 25), (35, 24), (40, 31), (23, 33)], 1)
h.poly([(18, 24), (34, 23), (38, 29), (22, 31)], 15)
d.line(21, 25, 33, 24, 17)
d.line(24, 31, 37, 29, 7)
d.line(43, 26, 49, 29, 18)
h.ellipse(55, 24, 9, 5, 1)
h.rect(55, 25, 8, 5, 6)
h.ellipse(55, 24, 8, 4, 8)
h.ellipse(57, 25, 4, 2, 15)
# Tucked upholstered chair; does not obstruct the room's front corridor.
b.poly([(28, 45), (49, 45), (55, 54), (49, 60), (26, 60), (23, 53)], 1)
h.poly([(28, 45), (48, 45), (52, 51), (47, 55), (27, 55), (25, 51)], 11)
h.line(29, 46, 46, 46, 12)
h.rect(26, 55, 24, 7, 10)
for x in [27, 45]:
    d.line(x, 62, x - 2, 69, 3)

s, b, h, d = asset("locker", 64, 56)
s.ellipse(1, 39, 62, 15, (4, 14, 20, 135))
b.poly([(7, 7), (51, 7), (61, 17), (61, 46), (8, 48), (2, 41), (2, 15)], 1)
h.poly([(8, 7), (50, 7), (57, 15), (6, 15)], 5)
h.rect(7, 16, 49, 27, 4)
h.rect(10, 18, 43, 22, 5)
h.poly([(57, 16), (60, 18), (60, 43), (56, 46)], 2)
d.rect(30, 19, 1, 20, 3)
for x in [13, 35]:
    d.vents(x, 23, 3, 13)
    d.rect(x + 3, 35, 7, 2, 2)
    d.dot(x + 3, 35, 7)
# Folded woven cloth, subdued burnt umber instead of more equipment lights.
h.poly([(13, 5), (37, 3), (47, 9), (44, 14), (13, 13)], 15)
h.line(15, 6, 35, 4, 17)
h.line(16, 9, 41, 9, 16)
h.line(17, 12, 41, 12, 17)
for x in range(20, 39, 3):
    d.dot(x, 8, 18)
d.bolts([(8, 17), (52, 39)])

s, b, h, d = asset("wall-light", 32, 32)
s.ellipse(0, 6, 32, 24, (15, 23, 26, 80))
b.poly([(7, 6), (23, 6), (29, 12), (27, 24), (6, 24), (3, 18), (3, 11)], 1)
h.poly([(7, 7), (23, 7), (26, 12), (24, 20), (7, 20), (5, 17), (5, 12)], 4)
h.poly([(8, 10), (22, 10), (24, 13), (22, 17), (8, 17), (6, 14)], 17)
h.rect(9, 11, 13, 4, 18)
d.line(10, 11, 20, 11, 19)
d.line(9, 16, 20, 16, 16)
d.bolts([(7, 8), (23, 19)])
d.vents(10, 22, 2, 10)

# Separate low-resolution light textures, editable in Aseprite, for native lights.
s, b, h, d = asset("light", 64, 64)
for y in range(64):
    for x in range(64):
        radius = math.sqrt(((x - 31.5) / 32) ** 2 + ((y - 31.5) / 32) ** 2)
        value = max(0, 1 - radius) ** 2
        if value > 0:
            b.dot(x, y, (255, 255, 255, int(value * 210) // 12 * 12))

# A hub-only avatar, same animator rows/frames and 32px cell scale.
s, b, h, d = asset("player", 96, 192)
for row in [3, 4, 5]:
    for frame in range(3):
        ox = frame * 32
        oy = row * 32
        stride = [-1, 0, 1][frame]
        # Backpack, boots and compact off-white pressure suit.
        b.rect(ox + 9, oy + 10, 15, 14, 0)
        b.rect(ox + 11, oy + 22 + stride, 5, 6, 0)
        b.rect(ox + 18, oy + 22 - stride, 5, 6, 0)
        h.rect(ox + 12, oy + 23 + stride, 3, 3, 3)
        h.rect(ox + 18, oy + 23 - stride, 3, 3, 4)
        b.poly(
            [
                (ox + 11, oy + 10),
                (ox + 20, oy + 10),
                (ox + 24, oy + 17),
                (ox + 22, oy + 23),
                (ox + 10, oy + 23),
                (ox + 8, oy + 17),
            ],
            1,
        )
        h.rect(ox + 11, oy + 13, 10, 10, 5)
        h.rect(ox + 12, oy + 13, 6, 8, 7)
        h.rect(ox + 10, oy + 21, 12, 2, 3)
        d.rect(ox + 15, oy + 21, 3, 1, 6)
        for xx in [8, 22]:
            h.rect(ox + xx, oy + 15, 3, 7, 6)
            d.rect(ox + xx, oy + 21, 3, 2, 2)
        b.poly(
            [
                (ox + 11, oy + 2),
                (ox + 20, oy + 2),
                (ox + 24, oy + 6),
                (ox + 24, oy + 12),
                (ox + 20, oy + 15),
                (ox + 10, oy + 15),
                (ox + 7, oy + 11),
                (ox + 7, oy + 6),
            ],
            0,
        )
        h.poly(
            [
                (ox + 11, oy + 3),
                (ox + 20, oy + 3),
                (ox + 22, oy + 6),
                (ox + 22, oy + 11),
                (ox + 19, oy + 13),
                (ox + 11, oy + 13),
                (ox + 9, oy + 10),
                (ox + 9, oy + 6),
            ],
            6,
        )
        d.line(ox + 12, oy + 3, ox + 19, oy + 3, 8)
        if row == 3:
            h.rect(ox + 11, oy + 6, 10, 5, 1)
            d.rect(ox + 12, oy + 7, 8, 2, 12)
            d.rect(ox + 12, oy + 7, 3, 1, 14)
            d.rect(ox + 13, oy + 16, 6, 3, 15)
            d.rect(ox + 14, oy + 16, 4, 1, 17)
        elif row == 4:
            h.rect(ox + 17, oy + 6, 5, 5, 1)
            d.rect(ox + 18, oy + 7, 4, 2, 12)
            h.rect(ox + 10, oy + 15, 5, 7, 3)
            d.line(ox + 10, oy + 15, ox + 14, oy + 15, 5)
        else:
            h.rect(ox + 11, oy + 6, 9, 5, 5)
            d.line(ox + 12, oy + 6, ox + 19, oy + 6, 7)
            h.rect(ox + 12, oy + 15, 8, 7, 3)
            d.line(ox + 13, oy + 15, ox + 18, oy + 15, 5)
            d.rect(ox + 14, oy + 18, 4, 1, 12)


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
