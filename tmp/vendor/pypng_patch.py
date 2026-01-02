import sys
from pathlib import Path

def patch_setup(path):
    p = Path(path)
    s = p.read_text()
    # remove use_2to3 references
    s = s.replace("conf['use_2to3'] = True", "")
    s = s.replace("use_2to3=True,", "")
    p.write_text(s)

if __name__ == '__main__':
    patch_setup(sys.argv[1])
