from pathlib import Path
import sys


CODE_DIR = Path(__file__).resolve().parent / "code"
if str(CODE_DIR) not in sys.path:
	sys.path.insert(0, str(CODE_DIR))

from settings import *  # noqa: F401,F403
