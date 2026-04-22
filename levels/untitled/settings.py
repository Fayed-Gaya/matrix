from __future__ import annotations

Color = tuple[int, int, int]

WIDTH: int = 960
HEIGHT: int = 540
FPS: int = 60

TILE_SIZE: int = 32

PLAYER_SPEED: int = 260
PLAYER_SIZE: tuple[int, int] = (30, 38)

NPC_SIZE: tuple[int, int] = (34, 42)
INTERACTION_DISTANCE: int = 64

BG_COLOR: Color = (18, 27, 23)
GROUND_COLOR: Color = (38, 61, 45)
GRASS_COLOR: Color = (45, 88, 56)
TREE_COLOR: Color = (24, 54, 36)
ROCK_COLOR: Color = (92, 104, 96)
WATER_COLOR: Color = (38, 78, 88)
PLAYER_COLOR: Color = (112, 220, 172)
NPC_COLOR: Color = (218, 186, 112)
NPC_ACCENT_COLOR: Color = (64, 38, 28)
TEXT_COLOR: Color = (236, 238, 224)
MUTED_TEXT_COLOR: Color = (172, 184, 166)
DIALOG_BG_COLOR: Color = (14, 22, 20)
DIALOG_BORDER_COLOR: Color = (112, 188, 150)
SHADOW_COLOR: Color = (8, 12, 10)
OVERLAY_COLOR: Color = (0, 0, 0)

DIALOGUE_TEXT: str = (
    "The truth is I got on that bus a boy, and I never got off the bus. I still haven't."
)
