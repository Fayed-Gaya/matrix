from csv import reader
from os import walk
from pathlib import Path

import pygame


def import_csv_layout(path):
    terrain_map = []
    with open(Path(path), newline="") as level_map:
        layout = reader(level_map, delimiter=",")
        for row in layout:
            terrain_map.append(list(row))
        return terrain_map


def import_folder(path):
    surface_list = []
    path = Path(path)

    for _, __, img_files in walk(path):
        for image in sorted(img_files):
            full_path = path / image
            image_surf = pygame.image.load(str(full_path)).convert_alpha()
            surface_list.append(image_surf)

    return surface_list
