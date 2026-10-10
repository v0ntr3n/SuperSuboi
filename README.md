# SuperSuboi — Zapret-only Windows UI

SuperSuboi is a Windows GUI for [Zapret](https://github.com/bol-van/zapret).
This fork uses **Zapret `winws.exe` only**. GoodbyeDPI, ByeDPI, SpoofDPI,
and ProxiFyre are not selectable engines or visible setup options.

## Features

- Start and stop Zapret, including from the system tray.
- Select, edit, import, and export Zapret presets.
- Configure Zapret hostlists and update blocklists.
- Test Zapret strategies with GoodCheck.

## Requirements

- Windows 10 (64-bit), build 15063 or newer.
- Python and the packages in `requirements.txt` for source installs.
- Administrator privileges to run the Windows packet driver.

## Run on Windows (one-click)

Double-click **`launch.cmd`** in the repository root. The first time, select:

- **1 — Set up (recommended):** create a local `.venv`, install `requirements.txt`, and start the UI.
- **2 — Skip setup:** use an existing `.venv` or system Python with dependencies already installed.

After a successful setup, double-clicking `launch.cmd` reuses the environment
and launches the app immediately. The launcher also creates missing, ignored
`.env` and `config.properties` with working defaults; it never overwrites
your existing configuration. An optional GitHub API token can be placed in
`.env` later (`DEV_API=...`).

You can use the following command-line switches from **Command Prompt**:

```bat
launch.cmd --setup        REM Create/update .venv and launch
launch.cmd --skip         REM No package installation; launch with existing Python
launch.cmd --setup-only   REM Install dependencies without starting the UI
launch.cmd --check        REM Verify key Python imports
```

**Python 3.10+ must already be installed** to run `run.py`; Python 3.12
is recommended. The launcher creates a virtual environment automatically,
but cannot run the Python GUI without a Python interpreter. Windows may
prompt for administrator access when the app starts.

To start manually instead:

```powershell
python -m pip install -r requirements.txt
python run.py
```

The default launcher regenerates QML resources. Avoid `run.py --fast`
after editing QML until resources have been regenerated.

Open **Zapret** in the sidebar, choose a preset, and start the process.
GoodCheck can be used to test Zapret strategies.

## Notes

- The QML import name `GoodbyeDPI_UI` and some upstream implementation
  identifiers are intentionally retained for compatibility; they are not
  additional selectable engines.
- Existing users with a saved non-Zapret engine are switched to Zapret on
  application startup.
- Source-based builds have not been validated on a Windows machine as part
  of this cleanup.

## Credits

Based on the [GoodbyeDPI UI](https://github.com/Storik4pro/goodbyeDPI-UI)
project. Zapret is maintained by [bol-van](https://github.com/bol-van/zapret).
See [LICENSE](LICENSE) for licensing details.
