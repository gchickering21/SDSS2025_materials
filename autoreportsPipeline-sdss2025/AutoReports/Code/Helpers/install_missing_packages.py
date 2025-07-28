import importlib.util
import subprocess
import sys


def install_missing_packages(packages, load=False):
    # Update py_requirements.txt as needed
    with open("py_requirements.txt", "r+") as f:
        req_packages = packages
        py_requirements = f.read().splitlines()
        for package in req_packages:
            if package not in py_requirements:
                f.write(f"{package}\n")

    # Install missing packages
    for package in packages:
        spec = importlib.util.find_spec(package)
        if spec is None:
            if package == "ssl":
                print(
                    "\033[1;33mPackage 'ssl' not found. Installing all reqs...\033[0m"
                )
                subprocess.check_call(
                    [sys.executable, "-m", "pip", "install", "openssl-devel"]
                )
                subprocess.check_call(
                    [sys.executable, "-m", "pip", "install", "certifi"]
                )
            else:
                print(
                    f"\033[1;33mPackage '{package}' not found. Installing all reqs...\033[0m"
                )
                subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            if load:
                importlib.import_module(package)


# # Attempt to import needed packages -- old code
# packages = ['asyncio', 'platform', 're', 'ssl', 'argparse']
# # Update py_requirements.txt as needed
# with open('py_requirements.txt', 'r+') as f:
#     req_packages = packages
#     py_requirements = f.read().splitlines()
#     req_packages = req_packages + ['importlib','subprocess','sys']
#     for package in req_packages:
#         if package not in py_requirements:
#             f.write(f'{package}\n')
# missing_packages = []
# for package in packages:
#     try:
#         globals()[package] = importlib.import_module(package)
#     except ImportError:
#         missing_packages.append(package)
# # For each package not imported, attempt to install it
# missing_packages = list(set(missing_packages))
# if 'ssl' in missing_packages:
#     print("\033[1;33mPackage 'ssl' not found. Installing all reqs...\033[0m")
#     subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'openssl-devel'])
#     subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'certifi'])
# for package in missing_packages:
#     if package != 'ssl':
#         print(f"\033[1;33mPackage '{package}' not found. Installing all reqs...\033[0m")
#         subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
# # Reload newly installed packages
# for package in missing_packages:
#     globals()[package] = importlib.import_module(package)
