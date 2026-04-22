from __future__ import annotations

from pathlib import Path

import pygame
from pytmx import TiledObjectGroup, TiledTileLayer
from pytmx.util_pygame import load_pygame

from .interaction import NPC
from .paths import MAPS_DIR
from .settings import (
    DIALOGUE_TEXT,
    TILE_SIZE,
)


class World:
    def __init__(self, map_path: Path = MAPS_DIR / "area_earth.tmx") -> None:
        self.map_path = map_path
        self.tmx = load_pygame(str(map_path))
        self.bounds = pygame.Rect(
            0,
            0,
            self.tmx.width * self.tmx.tilewidth,
            self.tmx.height * self.tmx.tileheight,
        )
        self.collision_rects = self._load_collision_rects()
        self.player_spawn = self._load_named_point(
            "Spawn", "player", (TILE_SIZE * 6, TILE_SIZE * 7)
        )
        self.npcs = self._load_npcs()

    def draw(
        self, surface: pygame.Surface, camera_offset: pygame.Vector2, *, above: bool = False
    ) -> None:
        for layer in self.tmx.visible_layers:
            if not isinstance(layer, TiledTileLayer):
                continue
            if (layer.name == "Above") != above:
                continue

            for x, y, image in layer.tiles():
                if image is None:
                    continue
                draw_position = (
                    x * self.tmx.tilewidth - round(camera_offset.x),
                    y * self.tmx.tileheight - round(camera_offset.y),
                )
                surface.blit(image, draw_position)

    def _object_group(self, name: str) -> TiledObjectGroup | None:
        layer = self.tmx.get_layer_by_name(name)
        return layer if isinstance(layer, TiledObjectGroup) else None

    def _load_collision_rects(self) -> list[pygame.Rect]:
        group = self._object_group("Collision")
        if group is None:
            return []

        return [
            pygame.Rect(round(obj.x), round(obj.y), round(obj.width), round(obj.height))
            for obj in group
        ]

    def _load_named_point(
        self,
        layer_name: str,
        object_name: str,
        fallback: tuple[int, int],
    ) -> tuple[int, int]:
        group = self._object_group(layer_name)
        if group is None:
            return fallback

        for obj in group:
            if obj.name == object_name:
                return (round(obj.x), round(obj.y))

        return fallback

    def _load_npcs(self) -> list[NPC]:
        group = self._object_group("NPCs")
        if group is None:
            return []

        npcs: list[NPC] = []
        for obj in group:
            dialogue = obj.properties.get("dialogue", DIALOGUE_TEXT)
            npcs.append(NPC((round(obj.x), round(obj.y)), str(dialogue)))
        return npcs
