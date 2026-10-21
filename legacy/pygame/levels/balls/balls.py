import pygame

screen_width = 1280
screen_height = 720
frame_rate = 60


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


def run():
    pygame.init()
    screen = pygame.display.set_mode((screen_width, screen_height))
    clock = pygame.time.Clock()
    running = True
    dt = 0

    player_pos_1 = pygame.Vector2(screen.get_width() / 2 - 50, screen.get_height() / 2)
    player_pos_2 = pygame.Vector2(screen.get_width() / 2 + 50, screen.get_height() / 2)

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        screen.fill("purple")

        draw_wrapped_circle(screen, "red", player_pos_1, 40)
        draw_wrapped_circle(screen, "red", player_pos_2, 40)

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

        pygame.display.flip()

        dt = clock.tick(frame_rate) / 1000

    pygame.quit()


def main():
    run()


if __name__ == "__main__":
    run()
