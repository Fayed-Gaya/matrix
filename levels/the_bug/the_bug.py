from pathlib import Path
import sys
import pygame

try:
    from .debug import debug
except ImportError:
    from debug import debug

BASE_DIR = Path(__file__).resolve().parent


def run():
    pygame.init()
    screen = pygame.display.set_mode((600, 600))
    clock = pygame.time.Clock()
    cat_surf = pygame.image.load(str(BASE_DIR / 'cat.png')).convert_alpha()

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
        screen.fill('white')
        screen.blit(cat_surf, (15, 20))
        debug(pygame.mouse.get_pos())
        debug(pygame.mouse.get_pressed(), 40)
        debug('mouse!', pygame.mouse.get_pos()[1], pygame.mouse.get_pos()[0])

        pygame.display.update()
        clock.tick(60)


def main():
    run()


if __name__ == '__main__':
    run()
