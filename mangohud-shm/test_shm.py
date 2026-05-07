import os
import time
import subprocess
import shutil
import pytest
from typing import Generator

SHM_PATH: str = "/dev/shm/MangoHud"
EXPECTED_SIZE: int = 48

@pytest.fixture
def vkcube_mangohud() -> Generator[subprocess.Popen, None, None]:
    if os.path.exists(SHM_PATH):
        try: 
            os.remove(SHM_PATH)
        except OSError: 
            pass

    if not shutil.which("gamescope"):
        pytest.fail("gamescope not found! Install it by running: sudo pacman -S gamescope")

    clean_env: dict[str, str] = os.environ.copy()
    clean_env.pop("WAYLAND_DISPLAY", None)
    clean_env.pop("DISPLAY", None)

    cmd: list[str] = ["gamescope", "--backend", "headless", "--", "mangohud", "vkcube", "--c", "150"]

    process: subprocess.Popen = subprocess.Popen(
        cmd,
        env=clean_env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    file_created: bool = False
    for _ in range(50):
        if os.path.exists(SHM_PATH):
            file_created = True
            break
        time.sleep(0.1)
    
    if not file_created:
        process.terminate()
        pytest.fail("vkcube failed to open in headless mode.")
    
    yield process 

    if process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=3.0)
        except subprocess.TimeoutExpired:
            process.kill()

    subprocess.run(["pkill", "-9", "vkcube"], stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-9", "gamescope"], stderr=subprocess.DEVNULL)


def test_shm_creation(vkcube_mangohud: subprocess.Popen) -> None:
    assert os.path.exists(SHM_PATH), "The SHM file was not created."

def test_shm_size(vkcube_mangohud: subprocess.Popen) -> None:
    size: int = os.path.getsize(SHM_PATH)
    assert size == EXPECTED_SIZE, f"Size mismatch! Expected {EXPECTED_SIZE} bytes, got {size}."

def test_shm_deletion(vkcube_mangohud: subprocess.Popen) -> None:
    assert os.path.exists(SHM_PATH), "Setup failed: SHM file does not exist to be deleted."

    try:
        vkcube_mangohud.wait(timeout=5.0)
    except subprocess.TimeoutExpired:
        pytest.fail("vkcube did not close itself after 5 seconds!")
    
    time.sleep(0.2)

    assert not os.path.exists(SHM_PATH), "SHM file still exists after vkcube naturally finished! (Destructor didn't run)"
