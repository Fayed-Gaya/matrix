from __future__ import annotations

import pygame

from .registry import LevelEntry, get_level
from .settings import (
    ERROR_COLOR,
    MUTED_TEXT_COLOR,
    SUCCESS_COLOR,
    TERMINAL_COLOR,
    TEXT_COLOR,
)


class Terminal:
    def __init__(self, rect: pygame.Rect | tuple[int, int, int, int]) -> None:
        self.rect = pygame.Rect(rect)
        self.active = False
        self.input_text = ""
        self.message = ""
        self.message_color = MUTED_TEXT_COLOR
        self.font = pygame.font.Font(None, 28)
        self.small_font = pygame.font.Font(None, 22)

    def is_player_near(self, player_rect: pygame.Rect) -> bool:
        return self.rect.colliderect(player_rect)

    def open(self) -> None:
        self.active = True
        self.input_text = ""
        self.message = ""
        self.message_color = MUTED_TEXT_COLOR

    def close(self) -> None:
        self.active = False

    def handle_event(self, event: pygame.event.Event) -> LevelEntry | None:
        if not self.active or event.type != pygame.KEYDOWN:
            return None

        if event.key == pygame.K_ESCAPE:
            self.close()
            return None
        if event.key == pygame.K_BACKSPACE:
            self.input_text = self.input_text[:-1]
            return None
        if event.key == pygame.K_RETURN:
            return self.submit()

        if event.unicode and event.unicode.isprintable():
            if len(self.input_text) < 18:
                self.input_text += event.unicode.upper()
        return None

    def submit(self) -> LevelEntry | None:
        level = get_level(self.input_text)
        if level is None:
            self.message = f"Unknown code: {self.input_text or '<empty>'}"
            self.message_color = ERROR_COLOR
            self.input_text = ""
            return None

        self.message = f"Launching {level.name}..."
        self.message_color = SUCCESS_COLOR
        return level

    def draw_terminal_object(self, surface: pygame.Surface, player_near: bool) -> None:
        color = TEXT_COLOR if player_near else TERMINAL_COLOR
        pygame.draw.rect(surface, color, self.rect, border_radius=5)
        screen_rect = self.rect.inflate(-18, -18)
        pygame.draw.rect(surface, (4, 16, 20), screen_rect, border_radius=3)
        line_y = screen_rect.y + 9
        for i in range(3):
            pygame.draw.line(
                surface,
                color,
                (screen_rect.x + 10, line_y + i * 10),
                (screen_rect.right - 10, line_y + i * 10),
                2,
            )

    def draw_hint(self, surface: pygame.Surface) -> None:
        text = self.small_font.render("Press E to access terminal", True, TEXT_COLOR)
        width, height = surface.get_size()
        rect = text.get_rect(midbottom=(width // 2, height - 22))
        surface.blit(text, rect)

    def draw_overlay(self, surface: pygame.Surface) -> None:
        width, height = surface.get_size()
        surface.fill((2, 8, 10))

        prompt_rect = pygame.Rect(28, height - 76, width - 56, 46)
        pygame.draw.rect(surface, (0, 18, 16), prompt_rect)
        pygame.draw.rect(surface, TERMINAL_COLOR, prompt_rect, width=1)

        prompt = self.font.render(f"> {self.input_text}", True, SUCCESS_COLOR)
        surface.blit(prompt, (prompt_rect.x + 14, prompt_rect.y + 11))

        if self.message:
            message = self.small_font.render(self.message, True, self.message_color)
            surface.blit(message, (prompt_rect.x + 2, prompt_rect.y - 30))
