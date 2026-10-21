from __future__ import annotations

import importlib
from collections.abc import Callable
from dataclasses import dataclass
from typing import cast


@dataclass(frozen=True)
class LevelEntry:
    code: str
    name: str
    module: str
    description: str

    def launch(self) -> None:
        level_module = importlib.import_module(self.module)
        run = getattr(level_module, "run", None)
        if not callable(run):
            raise RuntimeError(f"{self.module} does not expose a callable run()")
        run = cast(Callable[[], None], run)
        run()


LEVELS: dict[str, LevelEntry] = {
    "JUMP": LevelEntry(
        code="JUMP",
        name="Jump",
        module="levels.jump",
        description="Endless runner",
    ),
    "MARIO": LevelEntry(
        code="MARIO",
        name="Mario",
        module="levels.mario",
        description="Platformer",
    ),
    "MONSTERS": LevelEntry(
        code="MONSTERS",
        name="Monsters",
        module="levels.monsters",
        description="Monster RPG",
    ),
    "ZELDA": LevelEntry(
        code="ZELDA",
        name="Zelda",
        module="levels.zelda",
        description="Top-down RPG",
    ),
    "PONG": LevelEntry(
        code="PONG",
        name="Tom Pong",
        module="levels.tom_pong",
        description="Two-player Pong",
    ),
    "BALLS": LevelEntry(
        code="BALLS",
        name="Balls",
        module="levels.balls",
        description="Movement and wraparound demo",
    ),
    "BOUNCE": LevelEntry(
        code="BOUNCE",
        name="Bouncing Ball",
        module="levels.bouncing_ball",
        description="Bouncing image demo",
    ),
    "BUG": LevelEntry(
        code="BUG",
        name="The Bug",
        module="levels.the_bug",
        description="Mouse debug demo",
    ),
    "YOU": LevelEntry(
        code="YOU",
        name="You",
        module="levels.you",
        description="Camera capture demo",
    ),
    "UNTITLED": LevelEntry(
        code="UNTITLED",
        name="Untitled Game",
        module="levels.untitled",
        description="2D action RPG prototype",
    ),
}


def codes() -> tuple[str, ...]:
    return tuple(LEVELS.keys())


def get_level(code: str) -> LevelEntry | None:
    return LEVELS.get(code.strip().upper())
