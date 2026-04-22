from __future__ import annotations

import pygame

from .settings import PLAYER_COLOR, PLAYER_SIZE, PLAYER_SPEED, SHADOW_COLOR


class Player:
    def __init__(self, position: tuple[int, int]) -> None:
        self.rect = pygame.Rect((0, 0), PLAYER_SIZE)
        self.rect.center = position

    def update(self, dt: float, collision_rects: list[pygame.Rect], bounds: pygame.Rect) -> None:
        direction = self._input_direction()
        if direction.length_squared() > 0:
            direction = direction.normalize()

        self._move_axis(round(direction.x * PLAYER_SPEED * dt), 0, collision_rects, bounds)
        self._move_axis(0, round(direction.y * PLAYER_SPEED * dt), collision_rects, bounds)

    def _input_direction(self) -> pygame.Vector2:
        keys = pygame.key.get_pressed()
        direction = pygame.Vector2()

        if keys[pygame.K_LEFT] or keys[pygame.K_a]:
            direction.x -= 1
        if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            direction.x += 1
        if keys[pygame.K_UP] or keys[pygame.K_w]:
            direction.y -= 1
        if keys[pygame.K_DOWN] or keys[pygame.K_s]:
            direction.y += 1

        return direction

    def _move_axis(
        self,
        dx: int,
        dy: int,
        collision_rects: list[pygame.Rect],
        bounds: pygame.Rect,
    ) -> None:
        self.rect.x += dx
        self.rect.y += dy
        self.rect.clamp_ip(bounds)

        for obstacle in collision_rects:
            if not self.rect.colliderect(obstacle):
                continue

            if dx > 0:
                self.rect.right = obstacle.left
            elif dx < 0:
                self.rect.left = obstacle.right
            elif dy > 0:
                self.rect.bottom = obstacle.top
            elif dy < 0:
                self.rect.top = obstacle.bottom

    def draw(self, surface: pygame.Surface, camera_offset: pygame.Vector2) -> None:
        draw_rect = self.rect.move(-round(camera_offset.x), -round(camera_offset.y))
        shadow = pygame.Rect(draw_rect.x + 3, draw_rect.bottom - 7, draw_rect.width - 6, 8)
        pygame.draw.ellipse(surface, SHADOW_COLOR, shadow)
        pygame.draw.rect(surface, PLAYER_COLOR, draw_rect, border_radius=5)
        hood = pygame.Rect(draw_rect.x + 7, draw_rect.y + 6, draw_rect.width - 14, 9)
        pygame.draw.rect(surface, (24, 58, 48), hood, border_radius=3)
