from pathlib import Path
import sys
import pygame

BASE_DIR = Path(__file__).resolve().parent


def run():
    pygame.init()

    size = width, height = 1200, 1000
    speed = [1, 1]
    black = 0, 0, 0

    screen = pygame.display.set_mode(size)

    ball = pygame.image.load(str(BASE_DIR / 'intro_ball.gif'))
    ballrect = ball.get_rect()

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

        ballrect = ballrect.move(speed)
        if ballrect.left < 0 or ballrect.right > width:
            speed[0] = -speed[0]
        if ballrect.top < 0 or ballrect.bottom > height:
            speed[1] = -speed[1]

        screen.fill(black)
        screen.blit(ball, ballrect)
        pygame.display.flip()


def main():
    run()


if __name__ == '__main__':
    run()
