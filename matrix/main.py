from __future__ import annotations

import sys

import pygame

from .camera import Camera
from .paths import BACKGROUNDS_DIR
from .player import Player
from .registry import LevelEntry
from .settings import BG_COLOR, FPS, HEIGHT, MUTED_TEXT_COLOR, TEXT_COLOR, WIDTH
from .terminal import Terminal
from .world import World


class MatrixGame:
    def __init__(self) -> None:
        pygame.init()
        pygame.display.set_caption("Matrix")
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(None, 28)
        self.title_font = pygame.font.Font(None, 46)
        self.start_font = pygame.font.Font(None, 34)
        self.opening_background = self._load_opening_background()
        self.show_opening = True
        self.world = World()
        self.camera = Camera((WIDTH, HEIGHT), self.world.bounds.size)
        self.player = Player(self.world.player_spawn)
        self.terminal = Terminal(self.world.terminal_rect)
        self.running = True
        self.level_to_launch: LevelEntry | None = None

    def run(self) -> None:
        while self.running:
            dt = self.clock.tick(FPS) / 1000
            self.handle_events()
            self.update(dt)
            self.draw()

            if self.level_to_launch is not None:
                self.launch_level(self.level_to_launch)

        pygame.quit()

    def handle_events(self) -> None:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
                return

            if self.show_opening:
                if event.type == pygame.KEYDOWN:
                    self.show_opening = False
                continue

            if self.terminal.active:
                level = self.terminal.handle_event(event)
                if level is not None:
                    self.level_to_launch = level
                continue

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.running = False
                elif event.key == pygame.K_e and self.terminal.is_player_near(self.player.rect):
                    self.terminal.open()

    def update(self, dt: float) -> None:
        if self.show_opening:
            return

        if not self.terminal.active:
            self.player.update(dt, self.world.collision_rects, self.world.bounds)
        self.camera.update(self.player.rect)

    def draw_room(self) -> None:
        self.screen.fill(BG_COLOR)
        self.world.draw(self.screen, self.camera.offset)

        title = self.title_font.render("MATRIX", True, TEXT_COLOR)
        self.screen.blit(title, (34, 30))

        subtitle = self.font.render("Find the terminal. Enter a level code.", True, TEXT_COLOR)
        self.screen.blit(subtitle, (36, 76))

    def draw(self) -> None:
        if self.show_opening:
            self.draw_opening()
            pygame.display.flip()
            return

        player_near_terminal = self.terminal.is_player_near(self.player.rect)
        self.draw_room()
        self.player.draw(self.screen, self.camera.offset)
        self.world.draw(self.screen, self.camera.offset, above=True)

        if player_near_terminal and not self.terminal.active:
            self.terminal.draw_hint(self.screen)
        if self.terminal.active:
            self.terminal.draw_overlay(self.screen)

        pygame.display.flip()

    def draw_opening(self) -> None:
        self.screen.blit(self.opening_background, (0, 0))

        prompt = self.start_font.render("Press start (any key) to begin", True, TEXT_COLOR)
        prompt_rect = prompt.get_rect(midtop=(WIDTH // 2, HEIGHT - 82))

        shadow = self.start_font.render("Press start (any key) to begin", True, (0, 0, 0))
        self.screen.blit(shadow, prompt_rect.move(2, 2))
        self.screen.blit(prompt, prompt_rect)

        hint = self.font.render("MATRIX", True, MUTED_TEXT_COLOR)
        hint_rect = hint.get_rect(midtop=(WIDTH // 2, prompt_rect.bottom + 10))
        self.screen.blit(hint, hint_rect)

    def _load_opening_background(self) -> pygame.Surface:
        image = pygame.image.load(BACKGROUNDS_DIR / "matrix-opening.jpg").convert()
        image_rect = image.get_rect()
        scale = max(WIDTH / image_rect.width, HEIGHT / image_rect.height)
        scaled_size = (round(image_rect.width * scale), round(image_rect.height * scale))
        image = pygame.transform.smoothscale(image, scaled_size)
        crop_rect = pygame.Rect(0, 0, WIDTH, HEIGHT)
        crop_rect.center = image.get_rect().center
        return image.subsurface(crop_rect).copy()

    def launch_level(self, level: LevelEntry) -> None:
        pygame.quit()
        level.launch()
        sys.exit()


def run() -> None:
    MatrixGame().run()


def main() -> None:
    run()


if __name__ == "__main__":
    run()
