#!/usr/bin/env python3
"""Date filter adapted from the course's Lab 3 Python example.

Source: https://docs.google.com/document/d/1Ubfi15uduKb4DjIYszmGdIclY_7THNAHx6gQnqCo5iI/edit
"""

from datetime import datetime
import os
import re


def list_items_older_than(date_input):
    try:
        if not re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", date_input):
            raise ValueError
        cutoff = datetime.strptime(date_input, "%Y-%m-%d").timestamp()
    except ValueError:
        print("Invalid date. Please use a valid YYYY-MM-DD date.")
        return

    found = False
    for name in sorted(os.listdir(".")):
        try:
            ctime = os.path.getctime(name)
            if ctime < cutoff:
                kind = "Folder" if os.path.isdir(name) else "File"
                stamp = datetime.fromtimestamp(ctime).strftime("%Y-%m-%d %H:%M:%S")
                print(f"{name} ({kind}, ctime: {stamp})")
                found = True
        except OSError as error:
            print(f"Cannot inspect {name}: {error.strerror}")
    if not found:
        print("No matching files or folders.")


def toy_shell():
    print("Toy shell: list entries older than a date using ctime.")
    print("Enter YYYY-MM-DD or 'exit'. On Unix, ctime is a metadata-change time.")
    while True:
        try:
            command = input("toy-shell> ").strip()
            if command.lower() == "exit":
                print("Exiting toy shell.")
                break
            list_items_older_than(command)
        except EOFError:
            print("\nExiting toy shell.")
            break
        except KeyboardInterrupt:
            print("\nUse 'exit' to quit the shell.")


if __name__ == "__main__":
    toy_shell()
