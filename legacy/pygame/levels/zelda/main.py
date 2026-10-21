import sys
from pathlib import Path

CODE_DIR = Path(__file__).resolve().parent / "code"
if str(CODE_DIR) not in sys.path:
    sys.path.insert(0, str(CODE_DIR))

from main import Game

if __name__ == "__main__":
    Game().run()
