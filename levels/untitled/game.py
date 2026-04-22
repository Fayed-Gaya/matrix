from __future__ import annotations

import pygame

from .camera import Camera
from .interaction import NPC, DialogueBox
from .player import Player
from .settings import (
    BG_COLOR,
    FPS,
    HEIGHT,
    MUTED_TEXT_COLOR,
    TEXT_COLOR,
    WIDTH,
    WORLD_HEIGHT,
    WORLD_WIDTH,
)
from .world import World


class Game:
    def __init__(self) -> None:
        pygame.init()
        pygame.display.set_caption("Untitled Game")
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(None, 28)
        self.small_font = pygame.font.Font(None, 22)
        self.title_font = pygame.font.Font(None, 40)
        self.world = World()
        self.camera = Camera((WIDTH, HEIGHT), (WORLD_WIDTH, WORLD_HEIGHT))
        self.player = Player((210, 230))
        self.npc = NPC((560, 330))
        self.dialogue = DialogueBox()
        self.running = True

    def run(self) -> None:
        while self.running:
            dt = self.clock.tick(FPS) / 1000
            self.handle_events()
            self.update(dt)
            self.draw()

        pygame.quit()

    def handle_events(self) -> None:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
                return

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    if self.dialogue.visible:
                        self.dialogue.hide()
                    else:
                        self.running = False
                elif event.key == pygame.K_e and self.npc.is_player_near(self.player.rect):
                    self.dialogue.toggle(self.npc.dialogue)

    def update(self, dt: float) -> None:
        if not self.dialogue.visible:
            self.player.update(dt, self.world.collision_rects, self.world.bounds)
        self.camera.update(self.player.rect)

    def draw(self) -> None:
        self.screen.fill(BG_COLOR)
        self.world.draw(self.screen, self.camera.offset)
        self.npc.draw(self.screen, self.camera.offset)
        self.player.draw(self.screen, self.camera.offset)
        self.draw_hud()
        self.dialogue.draw(self.screen, self.font, self.small_font)
        pygame.display.flip()

    def draw_hud(self) -> None:
        title = self.title_font.render("Untitled Game", True, TEXT_COLOR)
        self.screen.blit(title, (24, 22))

        if self.npc.is_player_near(self.player.rect) and not self.dialogue.visible:
            hint = self.small_font.render("Press E to talk", True, MUTED_TEXT_COLOR)
            self.screen.blit(hint, (24, 62))
