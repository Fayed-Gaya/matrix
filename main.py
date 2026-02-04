import pygame
from sys import exit

from pygame import mouse

pygame.init()

width = 800
height = 400
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption('Matrix')
clock = pygame.time.Clock()
test_font = pygame.font.Font('font/Pixeltype.ttf', 50)

sky_surface = pygame.image.load('graphics/Sky.png').convert()
ground_surface = pygame.image.load('graphics/ground.png').convert()

score_surf = test_font.render('Matrix', False, (64, 64, 64)).convert()
score_rect = score_surf.get_rect(center = (400, 50))

snail_surface = pygame.image.load('graphics/snail/snail1.png').convert_alpha()
snail_rect = snail_surface.get_rect(bottomright = (600, 300))

player_surf = pygame.image.load('graphics/player/player_walk_1.png').convert_alpha()
player_rect = player_surf.get_rect(midbottom = (80,300))

player_gravity = 0

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            exit()
        if event.type == pygame.MOUSEBUTTONDOWN:
            if player_rect.collidepoint(event.pos): player_gravity = -20

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                player_gravity = -20

    screen.blit(sky_surface, (0, 0))
    screen.blit(ground_surface, (0, 300))
    pygame.draw.rect(screen, '#c0e8ec', score_rect, 10)
    pygame.draw.rect(screen, '#c0e8ec', score_rect)
    screen.blit(score_surf, score_rect)

    snail_rect.left -= 4
    if snail_rect.left <= -100: snail_rect.left = 800
    screen.blit(snail_surface, snail_rect)

    # Player
    player_gravity += 1
    player_rect.y += player_gravity
    screen.blit(player_surf, player_rect)


    pygame.display.update()
    clock.tick(60)
