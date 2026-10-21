from __future__ import annotations

import pygame

from .paths import SPRITES_DIR
from .settings import ANIMATION_FPS, PLAYER_SIZE, PLAYER_SPEED
from .sprites import load_character_animations


class Player:
    def __init__(self, pos: tuple[int, int]) -> None:
        self.rect = pygame.Rect((0, 0), PLAYER_SIZE)
        self.rect.center = pos
        self.animations = load_character_animations(SPRITES_DIR / "player_snoblin.png")
        self.facing = "down"
        self.frame_index = 0.0
        self.moving = False

    def update(self, dt: float, collision_rects: list[pygame.Rect], bounds: pygame.Rect) -> None:
        direction = self._input_direction()
        if direction.length_squared() > 0:
            direction = direction.normalize()
            self.moving = True
            if abs(direction.x) > abs(direction.y):
                self.facing = "right" if direction.x > 0 else "left"
            else:
                self.facing = "down" if direction.y > 0 else "up"
        else:
            self.moving = False
            self.frame_index = 0.0

        self._move_axis(round(direction.x * PLAYER_SPEED * dt), 0, collision_rects, bounds)
        self._move_axis(0, round(direction.y * PLAYER_SPEED * dt), collision_rects, bounds)
        if self.moving:
            self.frame_index = (self.frame_index + ANIMATION_FPS * dt) % len(
                self.animations[self.facing]
            )

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
        frame = self._current_frame()
        sprite_rect = frame.get_rect(midbottom=(draw_rect.centerx, draw_rect.bottom + 4))
        shadow_rect = pygame.Rect(0, 0, 16, 8)
        shadow_rect.midbottom = (draw_rect.centerx, draw_rect.bottom + 2)
        pygame.draw.ellipse(surface, (8, 12, 10, 180), shadow_rect)
        surface.blit(frame, sprite_rect)

    def _current_frame(self) -> pygame.Surface:
        frames = self.animations[self.facing]
        index = int(self.frame_index) if self.moving else 1
        return frames[index % len(frames)]
