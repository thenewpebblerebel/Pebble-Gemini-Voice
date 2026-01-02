import sys
from pathlib import Path
import re

def patch_setup(path):
    p = Path(path)
    s = p.read_text()
    # Remove explicit import of build_py_2to3 and build_scripts_2to3
    s = re.sub(r"from distutils.command.build_py import build_py_2to3.*\n", "", s)
    s = re.sub(r"from distutils.command.build_scripts import build_scripts_2to3.*\n", "", s)
    # Remove raises about missing build_py_2to3
    s = re.sub(r"raise ImportError\([^)]+\)\n", "", s)
    # Strip use_2to3 occurrences
    s = re.sub(r"use_2to3[\s=,]*True,?", "", s)
    # If necessary, prepend a safe fallback
    if 'build_py_2to3' not in s:
        fallback = '\ntry:\n    from distutils.command.build_py import build_py_2to3\nexcept Exception:\n    from distutils.command.build_py import build_py as build_py_2to3\ntry:\n    from distutils.command.build_scripts import build_scripts_2to3\nexcept Exception:\n    from distutils.command.build_scripts import build_scripts as build_scripts_2to3\n'
        s = fallback + s
    p.write_text(s)

if __name__ == '__main__':
    patch_setup(sys.argv[1])
