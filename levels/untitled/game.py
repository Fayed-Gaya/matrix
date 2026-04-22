from __future__ import annotations

import pygame

from .camera import Camera
from .interaction import NPC, DialogueBox
from .paths import AUDIO_DIR, BACKGROUNDS_DIR
from .player import Player
from .settings import (
    BG_COLOR,
    FPS,
    HEIGHT,
    MUTED_TEXT_COLOR,
    OVERLAY_COLOR,
    TEXT_COLOR,
    WIDTH,
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
        self.camera = Camera((WIDTH, HEIGHT), self.world.bounds.size)
        self.player = Player(self.world.player_spawn)
        self.dialogue = DialogueBox()
        self.running = True
        self.opening = True
        self.opening_background = self._load_opening_background()
        self.music_started = False
        self.music_available = True

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
                elif self.opening and event.key in (pygame.K_SPACE, pygame.K_RETURN):
                    self.opening = False
                elif event.key == pygame.K_e:
                    npc = self.nearby_npc()
                    if npc is not None:
                        self.dialogue.toggle(npc.dialogue)

    def update(self, dt: float) -> None:
        if not self.music_started:
            self._start_music()

        if not self.opening and not self.dialogue.visible:
            self.player.update(dt, self.world.collision_rects, self.world.bounds)
        self.camera.update(self.player.rect)

    def draw(self) -> None:
        if self.opening:
            self.draw_opening()
            pygame.display.flip()
            return

        self.screen.fill(BG_COLOR)
        self.world.draw(self.screen, self.camera.offset)
        for npc in self.world.npcs:
            npc.draw(self.screen, self.camera.offset)
        self.player.draw(self.screen, self.camera.offset)
        self.world.draw(self.screen, self.camera.offset, above=True)
        self.draw_hud()
        self.dialogue.draw(self.screen, self.font, self.small_font)
        pygame.display.flip()

    def draw_hud(self) -> None:
        title = self.title_font.render("Untitled Game", True, TEXT_COLOR)
        self.screen.blit(title, (24, 22))

        if self.nearby_npc() is not None and not self.dialogue.visible:
            hint = self.small_font.render("Press E to talk", True, MUTED_TEXT_COLOR)
            self.screen.blit(hint, (24, 62))

    def nearby_npc(self) -> NPC | None:
        for npc in self.world.npcs:
            if npc.is_player_near(self.player.rect):
                return npc
        return None

    def draw_opening(self) -> None:
        if self.opening_background is not None:
            self.screen.blit(self.opening_background, (0, 0))
        else:
            self.screen.fill(BG_COLOR)

        shade = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
        shade.fill((*OVERLAY_COLOR, 92))
        self.screen.blit(shade, (0, 0))

        title = self.title_font.render("Untitled Game", True, TEXT_COLOR)
        prompt = self.font.render("Press Space to enter the forest", True, TEXT_COLOR)
        hint = self.small_font.render(
            "WASD or arrows to move. E to interact.", True, MUTED_TEXT_COLOR
        )

        self.screen.blit(title, title.get_rect(center=(WIDTH // 2, HEIGHT // 2 - 48)))
        self.screen.blit(prompt, prompt.get_rect(center=(WIDTH // 2, HEIGHT // 2 + 8)))
        self.screen.blit(hint, hint.get_rect(center=(WIDTH // 2, HEIGHT // 2 + 42)))

    def _load_opening_background(self) -> pygame.Surface | None:
        path = BACKGROUNDS_DIR / "environment_forestbackground.png"
        if not path.exists():
            return None

        background = pygame.image.load(path).convert()
        return pygame.transform.smoothscale(background, (WIDTH, HEIGHT))

    def _start_music(self) -> None:
        if not self.music_available:
            self.music_started = True
            return

        path = AUDIO_DIR / "forest_ambience.mp3"
        if not path.exists():
            self.music_started = True
            return

        try:
            pygame.mixer.music.load(path)
            pygame.mixer.music.set_volume(0.35)
            pygame.mixer.music.play(loops=-1)
        except pygame.error:
            self.music_available = False

        self.music_started = True
