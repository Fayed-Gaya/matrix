import pygame

from .registry import codes, get_level
from .settings import (
    ERROR_COLOR,
    HEIGHT,
    MUTED_TEXT_COLOR,
    SUCCESS_COLOR,
    TERMINAL_ACTIVE_COLOR,
    TERMINAL_COLOR,
    TEXT_COLOR,
    WIDTH,
)


class Terminal:
    def __init__(self, rect):
        self.rect = pygame.Rect(rect)
        self.active = False
        self.input_text = ""
        self.message = ""
        self.message_color = MUTED_TEXT_COLOR
        self.font = pygame.font.Font(None, 28)
        self.small_font = pygame.font.Font(None, 22)
        self.title_font = pygame.font.Font(None, 34)

    def is_player_near(self, player_rect):
        return self.rect.inflate(44, 44).colliderect(player_rect)

    def open(self):
        self.active = True
        self.input_text = ""
        self.message = "Enter a level code."
        self.message_color = MUTED_TEXT_COLOR

    def close(self):
        self.active = False

    def handle_event(self, event):
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

    def submit(self):
        level = get_level(self.input_text)
        if level is None:
            self.message = f"Unknown code: {self.input_text or '<empty>'}"
            self.message_color = ERROR_COLOR
            self.input_text = ""
            return None

        self.message = f"Launching {level.name}..."
        self.message_color = SUCCESS_COLOR
        return level

    def draw_terminal_object(self, surface, player_near):
        color = TERMINAL_ACTIVE_COLOR if player_near else TERMINAL_COLOR
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

    def draw_hint(self, surface):
        text = self.small_font.render("Press E to access terminal", True, TEXT_COLOR)
        rect = text.get_rect(midbottom=(WIDTH // 2, HEIGHT - 22))
        surface.blit(text, rect)

    def draw_overlay(self, surface):
        shade = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
        shade.fill((0, 0, 0, 150))
        surface.blit(shade, (0, 0))

        panel = pygame.Rect(120, 86, WIDTH - 240, HEIGHT - 172)
        pygame.draw.rect(surface, (8, 18, 22), panel, border_radius=6)
        pygame.draw.rect(surface, TERMINAL_COLOR, panel, width=2, border_radius=6)

        title = self.title_font.render("MATRIX TERMINAL", True, TEXT_COLOR)
        surface.blit(title, (panel.x + 26, panel.y + 24))

        available = "AVAILABLE: " + "  ".join(codes())
        available_surf = self.small_font.render(available, True, MUTED_TEXT_COLOR)
        surface.blit(available_surf, (panel.x + 26, panel.y + 68))

        prompt_rect = pygame.Rect(panel.x + 26, panel.y + 120, panel.width - 52, 44)
        pygame.draw.rect(surface, (2, 10, 12), prompt_rect, border_radius=4)
        pygame.draw.rect(surface, (40, 80, 88), prompt_rect, width=1, border_radius=4)
        prompt = self.font.render(f"> {self.input_text}", True, SUCCESS_COLOR)
        surface.blit(prompt, (prompt_rect.x + 14, prompt_rect.y + 11))

        message = self.small_font.render(self.message, True, self.message_color)
        surface.blit(message, (panel.x + 26, panel.y + 184))

        help_text = "Enter launches. Backspace edits. Escape closes."
        help_surf = self.small_font.render(help_text, True, MUTED_TEXT_COLOR)
        surface.blit(help_surf, (panel.x + 26, panel.bottom - 42))
