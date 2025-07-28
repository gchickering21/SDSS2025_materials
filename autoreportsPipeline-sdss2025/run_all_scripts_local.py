import os
import platform
import re
import subprocess
import asyncio
from AutoReports.Code.Helpers.install_missing_packages import install_missing_packages

try:
    import asyncio
except ImportError:
    install_missing_packages(["asyncio"], load=True)
try:
    import platform
except ImportError:
    install_missing_packages(["platform"], load=True)
try:
    import re
except ImportError:
    install_missing_packages(["re"], load=True)
try:
    import ssl
except ImportError:
    install_missing_packages(["ssl"], load=True)
try:
    import argparse
except ImportError:
    install_missing_packages(["argparse"], load=True)
try:
    import pandas as pd
except ImportError:
    install_missing_packages(["pandas"], load=False)
    import pandas as pd

def cleanup_container(container_name):
    """Stops and removes the Docker container with the given name, if it exists."""
    print(f"🔍 Checking for existing container '{container_name}'...")
    result = subprocess.run("docker ps -a", shell=True, stdout=subprocess.PIPE)
    if re.search(f"\\b{container_name}\\b", result.stdout.decode()):
        print(f"🧹 Stopping and removing existing container '{container_name}'...")
        subprocess.run(f"docker stop {container_name}", shell=True)
        subprocess.run(f"docker rm -f {container_name}", shell=True)

#gchickering/autoreports:SDSS2025
async def run_local_pipeline(container_name="autoreports_local", image_name = "gchickering/automated_reports:SDSS2025"):
    """Runs the AutoReports pipeline locally in Docker."""
    cleanup_container(container_name)

    # Determine OS and construct Docker run command
    os_type = platform.system().lower()
    if os_type in ["darwin", "linux"]:
        docker_run_cmd = (
            f"docker run -d -t --name {container_name} "
            f'-v "$(pwd)/AutoReports:/AutoReports" {image_name}'
        )
    elif os_type == "windows":
        docker_run_cmd = (
            f"docker run -d -t --name {container_name} "
            f'-v "%cd%\\AutoReports:/AutoReports" {image_name}'
        )
    else:
        raise RuntimeError("❌ Unsupported operating system for local pipeline.")

    print("🐳 Starting Docker container...")
    subprocess.run(docker_run_cmd, shell=True, check=True)
    await asyncio.sleep(3)

    print("📄 Running report script inside Docker container...")
    docker_exec_cmd = (
        f'docker exec {container_name} bash -c "cd /AutoReports && Rscript report_shell_parallel_local.R"'
    )
    subprocess.run(docker_exec_cmd, shell=True, check=True)

    print("✅ Report script finished. Cleaning up...")
    cleanup_container(container_name)

def main():
    try:
        asyncio.run(run_local_pipeline())
    except RuntimeError as e:
        # For environments where asyncio.run() cannot be used (e.g., Jupyter), fallback
        loop = asyncio.get_event_loop()
        loop.run_until_complete(run_local_pipeline())

if __name__ == "__main__":
    main()
