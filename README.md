# Monitor Workspaces for Omarchy

Monitor Workspaces is a native Omarchy Quattro bar widget that makes workspace
ownership visible in extended multi-monitor setups. Every workspace assigned to
a monitor uses the active color from the current Omarchy theme on that monitor's
bar.

![Monitor Workspaces preview](preview.png)

## Behavior

- Colors every workspace assigned to each monitor, not only the visible one.
- Updates immediately when a workspace moves between monitors.
- Preserves Omarchy's square glyph for the globally focused workspace.
- Uses the current theme's active bar color instead of a hard-coded color.
- Keeps the standard white indicators on a single monitor or in mirror mode.
- Reacts to monitor hot-plug, removal, mirroring, and extended-mode changes.
- Shows workspaces 1 through 5 by default and discovered workspaces through 10.

## Requirements

- Omarchy Quattro with the native Omarchy shell and bar.
- Hyprland and Quickshell as provided by Omarchy.

There are no additional packages, services, network calls, or privileged setup.
The widget reads monitor and workspace state from Quickshell. Clicking a
workspace invokes the Omarchy Hyprland dispatcher through `hyprctl`.

## Install

Install the repository, enable Monitor Workspaces beside the Omarchy menu, then
disable the built-in workspace widget:

```bash
omarchy plugin add https://github.com/vprenner/omarchy-monitor-workspaces.git
omarchy plugin enable io.github.vprenner.monitor-workspaces --section left --after omarchy.menu
omarchy plugin disable omarchy.workspaces
```

Review the source before enabling it. Omarchy plugins run unsandboxed with your
user permissions.

## Update

```bash
omarchy plugin update io.github.vprenner.monitor-workspaces
```

## Remove

Restore the built-in workspace widget before removing Monitor Workspaces:

```bash
omarchy plugin enable omarchy.workspaces --section left --after omarchy.menu
omarchy plugin remove io.github.vprenner.monitor-workspaces
```

## Development

Validate a checkout against the installed Omarchy shell:

```bash
omarchy plugin validate .
qmllint -I /usr/share/omarchy/shell Workspaces.qml
```

## Attribution

This plugin is derived from Omarchy's built-in workspace widget and is released
under the MIT License. See [LICENSE](LICENSE).
