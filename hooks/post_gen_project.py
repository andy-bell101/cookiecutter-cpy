#!/usr/bin/env python3

import os
import subprocess
import sys

def has_uv() -> bool:
    return subprocess.run(["uv", "--version"]).returncode == 0


def uv_synced() -> bool:
    return os.path.isfile("uv.lock")


def uv_sync() -> int:
    if "{{ cookiecutter.uv_sync }}" != "yes":
        return 0

    if uv_synced():
        print("UV already synced")
        return 0
    
    if not has_uv():
        print("Could not find uv executable!", file=sys.stderr)
        return 1

    subprocess.run(["uv", "sync"], check=True)
    print("uv synced")
    return 0

def has_git() -> bool:
    return subprocess.run(["git", "--version"]).returncode == 0


def git_initialised() -> bool:
    return os.path.isdir(".git")


def initialise_git() -> int:
    if "{{ cookiecutter.init_git }}" != "yes":
        return 0

    if git_initialised():
        print("Git already initialised")
        return 0

    if not has_git():
        print("Could not find git executable!", file=sys.stderr)
        return 1

    subprocess.run(["git", "init"], check=True)
    subprocess.run(["git", "add", "."], check=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], check=True)

    print("Git repository initialised")
    return 0


def main() -> int:
    if uv_sync():
        return 1
    return initialise_git()


if __name__ == "__main__":
    sys.exit(main())
