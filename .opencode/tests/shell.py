"""Run inside dbus-run-session: python3 .opencode/tests/shell.py."""
from pathlib import Path
import subprocess
import tempfile
import time

source = Path(__file__).resolve().parents[2] / "dot_config/quickshell/shell.qml"
with tempfile.TemporaryFile(mode="w+") as log:
    process = subprocess.Popen(["quickshell", "-p", str(source), "--no-color"], stdout=log, stderr=log)
    try:
        for _ in range(100):
            log.seek(0)
            output = log.read()
            if "Configuration Loaded" in output:
                break
            assert process.poll() is None, output
            time.sleep(0.1)
        else:
            raise AssertionError("Shell startup timed out")
        for command in ("clock", "audio", "battery", "display", "emoji", "menu", "launcher", "openRecent"):
            subprocess.run(["quickshell", "ipc", "--pid", str(process.pid), "call", "shell", command], check=True, capture_output=True, timeout=5)
            time.sleep(0.15)
            subprocess.run(["quickshell", "ipc", "--pid", str(process.pid), "call", "shell", "close"], check=True, capture_output=True, timeout=5)
        log.seek(0)
        output = log.read()
        assert not any(error in output for error in ("ERROR", "ReferenceError", "TypeError", "is not defined", "Unable to assign", "Binding loop", "Cannot assign", "Required property", "is not a function")), output
        print("Shell startup and all panel IPC checks passed")
    finally:
        process.terminate()
        process.wait(timeout=5)
