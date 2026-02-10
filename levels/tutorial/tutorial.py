# Example file showing a basic pygame "game loop"
import pygame

#pygame setup
pygame.init()
screen_width = 1280
screen_height = 720
screen = pygame.display.set_mode((screen_width, screen_height))
clock = pygame.time.Clock()
running = True
frame_rate = 60
dt = 0

player_pos_1 = pygame.Vector2(screen.get_width() / 2 - 50, screen.get_height() / 2)
player_pos_2 = pygame.Vector2(screen.get_width() / 2 + 50, screen.get_height() / 2)

while running:
    # poll for events
    # pygame.Quit event means the user clicked X to close your window
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # fill the screen with a color to wipe away anything from last frame
    screen.fill('purple')

    pygame.draw.circle(screen, 'red', player_pos_1, 40)
    pygame.draw.circle(screen, 'red', player_pos_2, 40)

    keys = pygame.key.get_pressed()
    if keys[pygame.K_w]:
        player_pos_1.y -= 300 * dt
        player_pos_2.y -= 300 / frame_rate
    if keys[pygame.K_s]:
        player_pos_1.y += 300 * dt
        player_pos_2.y += 300 / frame_rate
    if keys[pygame.K_a]:
        player_pos_1.x -= 300 * dt
        player_pos_2.x -= 300 / frame_rate
    if keys[pygame.K_d]:
        player_pos_1.x += 300 * dt
        player_pos_2.x += 300 / frame_rate

    # flip() the display to put your work on the screen
    pygame.display.flip()

    # limits FPS to 60
    # dt is delta time in seconds since last frame, used for frame rate independent physics.
    dt = clock.tick(frame_rate) / 1000

pygame.quit()

