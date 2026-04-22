from __future__ import annotations

import pygame

from .settings import (
    DIALOG_BG_COLOR,
    DIALOG_BORDER_COLOR,
    DIALOGUE_TEXT,
    HEIGHT,
    INTERACTION_DISTANCE,
    MUTED_TEXT_COLOR,
    NPC_ACCENT_COLOR,
    NPC_COLOR,
    NPC_SIZE,
    SHADOW_COLOR,
    TEXT_COLOR,
    WIDTH,
)


class NPC:
    def __init__(self, position: tuple[int, int]) -> None:
        self.rect = pygame.Rect((0, 0), NPC_SIZE)
        self.rect.center = position
        self.dialogue = DIALOGUE_TEXT

    def is_player_near(self, player_rect: pygame.Rect) -> bool:
        return self.rect.inflate(INTERACTION_DISTANCE, INTERACTION_DISTANCE).colliderect(
            player_rect
        )

    def draw(self, surface: pygame.Surface, camera_offset: pygame.Vector2) -> None:
        draw_rect = self.rect.move(-round(camera_offset.x), -round(camera_offset.y))
        shadow = pygame.Rect(draw_rect.x + 3, draw_rect.bottom - 7, draw_rect.width - 6, 8)
        pygame.draw.ellipse(surface, SHADOW_COLOR, shadow)
        pygame.draw.rect(surface, NPC_COLOR, draw_rect, border_radius=5)
        face = pygame.Rect(draw_rect.x + 8, draw_rect.y + 8, draw_rect.width - 16, 10)
        pygame.draw.rect(surface, NPC_ACCENT_COLOR, face, border_radius=3)


class DialogueBox:
    def __init__(self) -> None:
        self.visible = False
        self.text = ""

    def show(self, text: str) -> None:
        self.visible = True
        self.text = text

    def hide(self) -> None:
        self.visible = False

    def toggle(self, text: str) -> None:
        if self.visible:
            self.hide()
        else:
            self.show(text)

    def draw(
        self, surface: pygame.Surface, font: pygame.font.Font, small_font: pygame.font.Font
    ) -> None:
        if not self.visible:
            return

        panel = pygame.Rect(58, HEIGHT - 156, WIDTH - 116, 112)
        pygame.draw.rect(surface, DIALOG_BG_COLOR, panel, border_radius=6)
        pygame.draw.rect(surface, DIALOG_BORDER_COLOR, panel, width=2, border_radius=6)

        for index, line in enumerate(wrap_text(self.text, font, panel.width - 44)):
            rendered = font.render(line, True, TEXT_COLOR)
            surface.blit(rendered, (panel.x + 22, panel.y + 22 + index * 26))

        hint = small_font.render("Press E to close", True, MUTED_TEXT_COLOR)
        surface.blit(hint, (panel.right - hint.get_width() - 22, panel.bottom - 28))


def wrap_text(text: str, font: pygame.font.Font, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""

    for word in words:
        candidate = word if not current else f"{current} {word}"
        if font.size(candidate)[0] <= max_width:
            current = candidate
            continue

        if current:
            lines.append(current)
        current = word

    if current:
        lines.append(current)

    return lines
