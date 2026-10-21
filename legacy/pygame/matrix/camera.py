from __future__ import annotations

import pygame


class Camera:
    def __init__(self, viewport_size: tuple[int, int], world_size: tuple[int, int]) -> None:
        self.viewport = pygame.Rect((0, 0), viewport_size)
        self.world = pygame.Rect((0, 0), world_size)
        self.offset = pygame.Vector2()

    def set_viewport(self, viewport_size: tuple[int, int]) -> None:
        self.viewport.size = viewport_size
        self._clamp_offset()

    def update(self, target: pygame.Rect) -> None:
        self.offset.x = target.centerx - self.viewport.width / 2
        self.offset.y = target.centery - self.viewport.height / 2
        self._clamp_offset()

    def _clamp_offset(self) -> None:
        max_x = max(0, self.world.width - self.viewport.width)
        max_y = max(0, self.world.height - self.viewport.height)
        self.offset.x = max(0, min(self.offset.x, max_x))
        self.offset.y = max(0, min(self.offset.y, max_y))

    def apply(self, rect: pygame.Rect) -> pygame.Rect:
        return rect.move(-round(self.offset.x), -round(self.offset.y))
