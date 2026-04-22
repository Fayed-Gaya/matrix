from __future__ import annotations

from dataclasses import dataclass

import pygame

from .settings import (
    GRASS_COLOR,
    GROUND_COLOR,
    ROCK_COLOR,
    TREE_COLOR,
    WATER_COLOR,
    WORLD_HEIGHT,
    WORLD_WIDTH,
)


@dataclass(frozen=True)
class WorldObject:
    rect: pygame.Rect
    color: tuple[int, int, int]
    border_radius: int = 0


class World:
    def __init__(self) -> None:
        self.bounds = pygame.Rect(0, 0, WORLD_WIDTH, WORLD_HEIGHT)
        self.decorations = [
            WorldObject(pygame.Rect(0, 0, WORLD_WIDTH, WORLD_HEIGHT), GROUND_COLOR),
            WorldObject(pygame.Rect(140, 120, 360, 220), GRASS_COLOR, 18),
            WorldObject(pygame.Rect(980, 100, 320, 210), GRASS_COLOR, 18),
            WorldObject(pygame.Rect(1120, 690, 280, 210), GRASS_COLOR, 18),
            WorldObject(pygame.Rect(180, 760, 310, 190), GRASS_COLOR, 18),
            WorldObject(pygame.Rect(620, 420, 300, 120), WATER_COLOR, 20),
        ]
        self.collision_rects = [
            pygame.Rect(0, 0, WORLD_WIDTH, 32),
            pygame.Rect(0, WORLD_HEIGHT - 32, WORLD_WIDTH, 32),
            pygame.Rect(0, 0, 32, WORLD_HEIGHT),
            pygame.Rect(WORLD_WIDTH - 32, 0, 32, WORLD_HEIGHT),
            pygame.Rect(300, 230, 70, 90),
            pygame.Rect(440, 610, 96, 72),
            pygame.Rect(830, 250, 74, 92),
            pygame.Rect(1140, 400, 92, 88),
            pygame.Rect(670, 430, 210, 96),
        ]
        self.obstacles = [
            WorldObject(pygame.Rect(300, 230, 70, 90), TREE_COLOR, 14),
            WorldObject(pygame.Rect(440, 610, 96, 72), ROCK_COLOR, 18),
            WorldObject(pygame.Rect(830, 250, 74, 92), TREE_COLOR, 14),
            WorldObject(pygame.Rect(1140, 400, 92, 88), ROCK_COLOR, 18),
            WorldObject(pygame.Rect(670, 430, 210, 96), WATER_COLOR, 20),
        ]

    def draw(self, surface: pygame.Surface, camera_offset: pygame.Vector2) -> None:
        for item in [*self.decorations, *self.obstacles]:
            draw_rect = item.rect.move(-round(camera_offset.x), -round(camera_offset.y))
            if surface.get_rect().colliderect(draw_rect):
                pygame.draw.rect(surface, item.color, draw_rect, border_radius=item.border_radius)
