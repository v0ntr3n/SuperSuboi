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

## Run from source

```powershell
python -m pip install -r requirements.txt
python run.py
```

On the first run, `run.py` may ask for an optional GitHub API token and
generate `config.properties`. Fill in the generated properties, then rerun.
The default launcher regenerates the QML resources, so avoid `--fast`
after editing QML until those resources have been regenerated.

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
