#!/usr/bin/env python3

import os
import subprocess
import sys

def has_git() -> bool:
    return subprocess.run(["git", "--version"]).returncode == 0


def git_initialised() -> bool:
    return os.path.isdir(".git")


def main() -> None:
    if "{{ cookiecutter.init_git }}" != "yes":
        return

    if git_initialised():
        print("Git already initialised")
        return

    if not has_git():
        print("Could not find git executable!", file=sys.stderr)
        return

    subprocess.run(["git", "init"], check=True)
    subprocess.run(["git", "add", "."], check=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], check=True)

    print("Git repository initialised")


if __name__ == "__main__":
    main()
