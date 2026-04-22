from __future__ import annotations

import sys

import pygame

from .player import Player
from .registry import LevelEntry
from .settings import BG_COLOR, FPS, GRID_COLOR, HEIGHT, TEXT_COLOR, WALL_COLOR, WIDTH
from .terminal import Terminal


class MatrixGame:
    def __init__(self) -> None:
        pygame.init()
        pygame.display.set_caption("Matrix")
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(None, 28)
        self.title_font = pygame.font.Font(None, 46)
        self.player = Player((150, HEIGHT // 2))
        self.terminal = Terminal((WIDTH - 180, HEIGHT // 2 - 52, 86, 104))
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
        if not self.terminal.active:
            self.player.update(dt)

    def draw_grid(self) -> None:
        for x in range(0, WIDTH, 48):
            pygame.draw.line(self.screen, GRID_COLOR, (x, 0), (x, HEIGHT))
        for y in range(0, HEIGHT, 48):
            pygame.draw.line(self.screen, GRID_COLOR, (0, y), (WIDTH, y))

    def draw_room(self) -> None:
        self.screen.fill(BG_COLOR)
        self.draw_grid()
        pygame.draw.rect(self.screen, WALL_COLOR, (18, 18, WIDTH - 36, HEIGHT - 36), width=3)

        title = self.title_font.render("MATRIX", True, TEXT_COLOR)
        self.screen.blit(title, (34, 30))

        subtitle = self.font.render("Find the terminal. Enter a level code.", True, TEXT_COLOR)
        self.screen.blit(subtitle, (36, 76))

    def draw(self) -> None:
        player_near_terminal = self.terminal.is_player_near(self.player.rect)
        self.draw_room()
        self.terminal.draw_terminal_object(self.screen, player_near_terminal)
        self.player.draw(self.screen)

        if player_near_terminal and not self.terminal.active:
            self.terminal.draw_hint(self.screen)
        if self.terminal.active:
            self.terminal.draw_overlay(self.screen)

        pygame.display.flip()

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
