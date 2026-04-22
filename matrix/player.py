from __future__ import annotations

import pygame

from .settings import HEIGHT, PLAYER_COLOR, PLAYER_SPEED, WIDTH


class Player:
    def __init__(self, pos: tuple[int, int]) -> None:
        self.rect = pygame.Rect(0, 0, 28, 28)
        self.rect.center = pos

    def update(self, dt: float) -> None:
        keys = pygame.key.get_pressed()
        direction = pygame.Vector2(0, 0)

        if keys[pygame.K_LEFT] or keys[pygame.K_a]:
            direction.x -= 1
        if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            direction.x += 1
        if keys[pygame.K_UP] or keys[pygame.K_w]:
            direction.y -= 1
        if keys[pygame.K_DOWN] or keys[pygame.K_s]:
            direction.y += 1

        if direction.length_squared():
            direction = direction.normalize()

        self.rect.x += round(direction.x * PLAYER_SPEED * dt)
        self.rect.y += round(direction.y * PLAYER_SPEED * dt)
        self.rect.clamp_ip(pygame.Rect(24, 24, WIDTH - 48, HEIGHT - 48))

    def draw(self, surface: pygame.Surface) -> None:
        pygame.draw.rect(surface, PLAYER_COLOR, self.rect, border_radius=4)
        visor = pygame.Rect(self.rect.x + 7, self.rect.y + 7, 14, 6)
        pygame.draw.rect(surface, (8, 24, 24), visor, border_radius=2)
