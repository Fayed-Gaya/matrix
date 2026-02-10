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

def draw_wrapped_circle(surface, color, pos, radius):
    width, height = surface.get_size()
    x, y = pos

    pygame.draw.circle(surface, color, (x, y), radius)

    if x - radius < 0:
        pygame.draw.circle(surface, color, (x + width, y), radius)
    elif x + radius > width:
        pygame.draw.circle(surface, color, (x - width, y), radius)

    if y - radius < 0:
        pygame.draw.circle(surface, color, (x, y + height), radius)
    elif y + radius > height:
        pygame.draw.circle(surface, color, (x, y - height), radius)

    if x - radius < 0 and y - radius < 0:
        pygame.draw.circle(surface, color, (x + width, y + height), radius)
    if x - radius < 0 and y + radius > height:
        pygame.draw.circle(surface, color, (x + width, y - height), radius)
    if x + radius > width and y - radius < 0:
        pygame.draw.circle(surface, color, (x - width, y + height), radius)
    if x + radius > width and y + radius > height:
        pygame.draw.circle(surface, color, (x - width, y - height), radius)

while running:
    # poll for events
    # pygame.Quit event means the user clicked X to close your window
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # fill the screen with a color to wipe away anything from last frame
    screen.fill('purple')

    draw_wrapped_circle(screen, 'red', player_pos_1, 40)
    draw_wrapped_circle(screen, 'red', player_pos_2, 40)

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

    player_pos_1.x %= screen_width
    player_pos_1.y %= screen_height
    player_pos_2.x %= screen_width
    player_pos_2.y %= screen_height

    # flip() the display to put your work on the screen
    pygame.display.flip()

    # limits FPS to 60
    # dt is delta time in seconds since last frame, used for frame rate independent physics.
    dt = clock.tick(frame_rate) / 1000

pygame.quit()
