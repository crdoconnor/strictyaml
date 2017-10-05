import pstats
import sys

p = pstats.Stats(sys.argv[1])
p.sort_stats("cumulative")
p.print_stats()
