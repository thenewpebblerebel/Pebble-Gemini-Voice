import sys
from pathlib import Path
import re


def patch_setup(path):
    p = Path(path)
    s = p.read_text()
    # Replace the entire Python 3 2to3 handling block with a safe fallback
    fallback = (
        "try:\n"
        "    from distutils.command.build_py import build_py_2to3 as build_py\n"
        "    from distutils.command.build_scripts import build_scripts_2to3 as build_scripts\n"
        "except Exception:\n"
        "    from distutils.command.build_py import build_py\n"
        "    from distutils.command.build_scripts import build_scripts\n\n"
    )
    # Replace from the 'if sys.version_info >= (3, 0):' up through the following 'else:' block
    s_new = re.sub(r"if sys\.version_info >= \(3, 0\):[\s\S]*?else:\s*from distutils\.command\.build_py[\s\S]*?from distutils\.command\.build_scripts[\s\S]*?\n", fallback, s, flags=re.M)
    if s_new != s:
        s = s_new

    # Remove explicit raises about missing build_py_2to3 (if any left)
    s = re.sub(r"^\s*raise ImportError\([^)]+\)\n", "", s, flags=re.M)

    # Strip use_2to3 occurrences
    s = re.sub(r"use_2to3[\s=,]*True,?", "", s)

    p.write_text(s)


if __name__ == '__main__':
    patch_setup(sys.argv[1])
