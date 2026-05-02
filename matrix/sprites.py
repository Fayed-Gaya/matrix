from __future__ import annotations

from pathlib import Path

import pygame

from .settings import CHARACTER_FRAME_SIZE


def load_character_animations(path: Path) -> dict[str, list[pygame.Surface]]:
    sheet = pygame.image.load(path).convert_alpha()
    frame_width, frame_height = CHARACTER_FRAME_SIZE

    down = _extract_row(sheet, 3, frame_width, frame_height)
    right = _extract_row(sheet, 4, frame_width, frame_height)
    up = _extract_row(sheet, 5, frame_width, frame_height)
    left = [pygame.transform.flip(frame, True, False) for frame in right]

    return {
        "down": down,
        "right": right,
        "up": up,
        "left": left,
    }


def _extract_row(
    sheet: pygame.Surface,
    row: int,
    frame_width: int,
    frame_height: int,
) -> list[pygame.Surface]:
    columns = sheet.get_width() // frame_width
    frames: list[pygame.Surface] = []

    for column in range(columns):
        frame = pygame.Surface((frame_width, frame_height), pygame.SRCALPHA)
        frame.blit(
            sheet,
            (0, 0),
            pygame.Rect(column * frame_width, row * frame_height, frame_width, frame_height),
        )
        frames.append(frame)

    return frames
