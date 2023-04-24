from hitchstory import StoryCollection
from engine import Engine
from pathquery import pathquery
from path import Path
import sys

PROJECT_DIR = Path(__file__).parent.parent

class Directories:
    gen = Path("/tmp/testgen")
    key = PROJECT_DIR / "hitch"
    project = PROJECT_DIR

DIR = Directories()

result = StoryCollection(
        pathquery(DIR.key / "story").ext("story"),
        Engine(DIR, python_path=sys.argv[1])
).only_uninherited().ordered_by_name().play()


if not result.all_passed:
    print("FAILURE")
    sys.exit(1)
