from pathlib import Path
import pygame
from sys import exit
from random import randint, choice


BASE_DIR = Path(__file__).resolve().parent


class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        walk_1 = pygame.image.load(str(BASE_DIR / 'graphics/player/player_walk_1.png')).convert_alpha()
        walk_2 = pygame.image.load(str(BASE_DIR / 'graphics/player/player_walk_2.png')).convert_alpha()
        self.player_jump = pygame.image.load(str(BASE_DIR / 'graphics/player/jump.png')).convert_alpha()
        self.player_walk = [walk_1, walk_2]
        self.player_index = 0

        self.image = self.player_walk[self.player_index]
        self.rect = self.image.get_rect(midbottom=(80, 300))
        self.gravity = 0

        self.jump_sound = pygame.mixer.Sound(str(BASE_DIR / 'audio/jump.mp3'))
        self.jump_sound.set_volume(0.25)
        self.reset()

    def reset(self):
        self.player_index = 0
        self.image = self.player_walk[self.player_index]
        self.rect = self.image.get_rect(midbottom=(80, 300))
        self.gravity = 0

    def player_input(self):
        keys = pygame.key.get_pressed()
        if keys[pygame.K_SPACE] and self.rect.bottom >= 300:
            self.gravity = -25
            self.jump_sound.play()

    def apply_gravity(self):
        self.gravity += 1
        self.rect.y += self.gravity
        if self.rect.bottom >= 300:
            self.rect.bottom = 300

    def animation_state(self):
        if self.rect.bottom < 300:
            self.image = self.player_jump
        else:
            self.player_index += 0.1
            if self.player_index >= len(self.player_walk):
                self.player_index = 0
            self.image = self.player_walk[int(self.player_index)]

    def update(self):
        self.player_input()
        self.apply_gravity()
        self.animation_state()


class Obstacle(pygame.sprite.Sprite):
    def __init__(self, obstacle_type):
        super().__init__()
        self.obstacle_type = obstacle_type
        if self.obstacle_type == 'fly':
            fly_1 = pygame.image.load(str(BASE_DIR / 'graphics/fly/Fly1.png')).convert_alpha()
            fly_2 = pygame.image.load(str(BASE_DIR / 'graphics/fly/Fly2.png')).convert_alpha()
            self.frames = [fly_1, fly_2]
            y_pos = 210
        else:
            snail_1 = pygame.image.load(str(BASE_DIR / 'graphics/snail/snail1.png')).convert_alpha()
            snail_2 = pygame.image.load(str(BASE_DIR / 'graphics/snail/snail2.png')).convert_alpha()
            self.frames = [snail_1, snail_2]
            y_pos = 300

        self.animation_index = 0
        self.image = self.frames[self.animation_index]
        self.rect = self.image.get_rect(midbottom=(randint(900, 1100), y_pos))

    def animation_state(self):
        if self.obstacle_type == 'fly':
            self.animation_index += 0.2
        else:
            self.animation_index += 0.025

        if self.animation_index >= len(self.frames):
            self.animation_index = 0
        self.image = self.frames[int(self.animation_index)]

    def destroy(self):
        if self.rect.x <= -100:
            self.kill()

    def update(self):
        self.animation_state()
        if self.obstacle_type == 'fly':
            self.rect.x -= 5
        else:
            self.rect.x -= 3
        self.destroy()


class Scoreboard:
    def __init__(self, font, color, position):
        self.font = font
        self.color = color
        self.position = position
        self.score = 0
        self.start_time = 0
        self.surface = None
        self.rect = None

    def reset(self, start_ticks):
        self.start_time = int(start_ticks / 1000)
        self.score = 0
        self.surface = None
        self.rect = None

    def update(self, ticks):
        current_time = int(ticks / 1000) - self.start_time
        self.score = current_time
        self.surface = self.font.render(f'Score: {current_time}', False, self.color)
        self.rect = self.surface.get_rect(center=self.position)

    def draw(self, screen):
        if self.surface is None or self.rect is None:
            return
        screen.blit(self.surface, self.rect)


class Game:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((800, 400))
        pygame.display.set_caption('Matrix')
        self.clock = pygame.time.Clock()
        self.font = pygame.font.Font(str(BASE_DIR / 'font/Pixeltype.ttf'), 50)

        self.bg_music = pygame.mixer.Sound(str(BASE_DIR / 'audio/music.wav'))
        self.bg_music.play(loops=-1)

        self.game_active = False

        self.player_group = pygame.sprite.GroupSingle()
        self.player_group.add(Player())
        self.obstacle_group = pygame.sprite.Group()

        self.scoreboard = Scoreboard(self.font, (64, 64, 64), (400, 50))

        self.load_assets()
        self.setup_timers()

    def load_assets(self):
        self.sky_surface = pygame.image.load(str(BASE_DIR / 'graphics/Sky.png')).convert()
        self.ground_surface = pygame.image.load(str(BASE_DIR / 'graphics/ground.png')).convert()

        self.game_name_surf = self.font.render('Jump', False, (111, 196, 169))
        self.game_name_rect = self.game_name_surf.get_rect(center=(400, 80))

        self.player_stand = pygame.image.load(
            str(BASE_DIR / 'graphics/player/player_stand.png')
        ).convert_alpha()
        self.player_stand = pygame.transform.rotozoom(self.player_stand, 0, 2)
        self.player_stand_rect = self.player_stand.get_rect(center=(400, 200))

        self.game_message_surf = self.font.render('Press space to run', False, (111, 196, 169))
        self.game_message_rect = self.game_message_surf.get_rect(center=(400, 340))

    def setup_timers(self):
        self.obstacle_timer = pygame.USEREVENT + 1
        pygame.time.set_timer(self.obstacle_timer, 1600)

    def reset(self):
        self.player_group.sprite.reset()
        self.scoreboard.reset(pygame.time.get_ticks())
        self.obstacle_group.empty()
        self.game_active = True

    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()

            if not self.game_active:
                if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                    self.reset()

            if self.game_active:
                if event.type == self.obstacle_timer:
                    self.obstacle_group.add(
                        Obstacle(choice(['fly', 'snail', 'snail', 'snail']))
                    )

    def check_collisions(self):
        if pygame.sprite.spritecollide(self.player_group.sprite, self.obstacle_group, False):
            self.obstacle_group.empty()
            return False
        return True

    def update(self):
        if self.game_active:
            self.player_group.update()
            self.obstacle_group.update()
            self.scoreboard.update(pygame.time.get_ticks())
            self.game_active = self.check_collisions()

    def render_game(self):
        self.screen.blit(self.sky_surface, (0, 0))
        self.screen.blit(self.ground_surface, (0, 300))
        self.scoreboard.draw(self.screen)
        self.player_group.draw(self.screen)
        self.obstacle_group.draw(self.screen)

    def render_intro(self):
        self.screen.fill((94, 129, 162))
        self.screen.blit(self.player_stand, self.player_stand_rect)
        self.screen.blit(self.game_name_surf, self.game_name_rect)
        if self.scoreboard.score:
            score_message = self.font.render(
                f'Your score: {self.scoreboard.score}', False, (111, 196, 169)
            )
            score_rect = score_message.get_rect(center=(400, 340))
            self.screen.blit(score_message, score_rect)
        else:
            self.screen.blit(self.game_message_surf, self.game_message_rect)

    def render(self):
        if self.game_active:
            self.render_game()
        else:
            self.render_intro()
        pygame.display.update()

    def run(self):
        while True:
            self.handle_events()
            self.update()
            self.render()
            self.clock.tick(60)


def jump():
    Game().run()


if __name__ == '__main__':
    jump()
