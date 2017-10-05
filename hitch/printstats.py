import pstats
import sys
import os

if os.path.exists(sys.argv[1]):
    p = pstats.Stats(sys.argv[1])
    p.sort_stats("cumulative")
    p.print_stats()
