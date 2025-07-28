import subprocess
import sys

def install_packages(requirements_file):
    try:
        with open(requirements_file, "r") as file:
            packages = file.read().splitlines()
            for package in packages:
                if package.strip():  # Ignore empty lines
                    print(f"Installing: {package}")
                    subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print("All packages installed successfully.")
    except Exception as e:
        print(f"An error occurred while installing packages: {e}")
        sys.exit(1)

if __name__ == "__main__":
    requirements_file = "py_requirements.txt"
    install_packages(requirements_file)