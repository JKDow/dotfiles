import os
import sys
import toml

# Path to the dotfiles directory and the config file

DOTFILES_DIR = os.path.expanduser("~/dotfiles")
CONFIG_FILE = os.path.join(DOTFILES_DIR, "stow_manager/stow-config.toml")


def stow_all():
    try:
        config = toml.load(CONFIG_FILE)
    except FileNotFoundError:
        sys.exit(f"Config file {CONFIG_FILE} not found!")
    except toml.TomlDecodeError:
        sys.exit(f"Error decoding TOML from {CONFIG_FILE}")

    for package in config.get("package", []):
        name = package.get("name")
        target = package.get("target", os.path.expanduser("~"))
        if not name:
            print("Package name is missing in config file, skipping...")
            continue
        package_dir = os.path.join(DOTFILES_DIR, name)
        if not os.path.isdir(package_dir):
            print(f"{package_dir} is not a directory, skipping...")
            continue
        print(f"Stowing {name} to {target}...")
        os.system(f"stow -t {target} -d {DOTFILES_DIR} {name}")


def unstow_all():
    # The unstow logic is similar to the stow logic.
    # Load the TOML file, and for each package run `stow -D`.
    print("Triggering Unstow")
    try:
        config = toml.load(CONFIG_FILE)
    except FileNotFoundError:
        sys.exit(f"Config file {CONFIG_FILE} not found!")
    except toml.TomlDecodeError:
        sys.exit(f"Error decoding TOML from {CONFIG_FILE}")

    for package in config.get("package", []):
        name = package.get("name")
        target = package.get("target", os.path.expanduser("~"))

        if not name:
            print("Package name is missing in config file, skipping...")
            continue

        print(f"Unstowing {name} from {target}...")
        os.system(f"stow -D -t {target} -d {DOTFILES_DIR} {name}")


if __name__ == "__main__":
    print("Starting python internal")
    if len(sys.argv) != 2 or sys.argv[1] not in {"stow", "unstow"}:
        print("syscrash")
        sys.exit("Usage: stow_manager.py <stow|unstow>")

    if sys.argv[1] == "stow":
        stow_all()
    else:
        unstow_all()

    print("Pythonend")
