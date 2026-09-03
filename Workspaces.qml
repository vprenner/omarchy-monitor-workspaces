import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.vprenner.monitor-workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function isExtendedDesktop() {
    var monitors = Hyprland.monitors.values
    if (monitors.length < 2) return false

    for (var i = 0; i < monitors.length; i++) {
      var state = monitors[i].lastIpcObject
      if (!state || String(state["mirrorOf"] || "") !== "none") return false
    }

    return true
  }

  function workspaceMonitorName(id) {
    var movedMonitor = movedWorkspaceMonitors[String(id)]
    if (movedMonitor !== undefined) return String(movedMonitor)

    var workspace = workspaceById(id)
    return workspace && workspace.monitor ? String(workspace.monitor.name || "") : ""
  }

  function rememberMovedWorkspace(id, monitorName) {
    var next = ({})
    for (var key in movedWorkspaceMonitors) next[key] = movedWorkspaceMonitors[key]
    next[String(id)] = String(monitorName)
    movedWorkspaceMonitors = next
  }

  function forgetMovedWorkspace(id) {
    var keyToForget = String(id)
    if (movedWorkspaceMonitors[keyToForget] === undefined) return

    var next = ({})
    for (var key in movedWorkspaceMonitors)
      if (key !== keyToForget) next[key] = movedWorkspaceMonitors[key]
    movedWorkspaceMonitors = next
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property var barWindow: root.QsWindow.window
  readonly property string screenName: barWindow && barWindow.screen
    ? String(barWindow.screen.name || "") : ""
  readonly property bool extendedDesktop: root.isExtendedDesktop()
  property var movedWorkspaceMonitors: ({})
  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (!event || !event.name) return
      var name = String(event.name)
      if (name === "moveworkspace" || name === "moveworkspacev2") {
        var fields = event.parse(name === "moveworkspacev2" ? 3 : 2)
        var workspaceId = Number(fields[0])
        var destinationMonitor = String(fields[fields.length - 1] || "")

        if (isFinite(workspaceId) && workspaceId > 0 && destinationMonitor !== "")
          root.rememberMovedWorkspace(workspaceId, destinationMonitor)

        workspaceMoveRefresh.restart()
      } else if (name === "destroyworkspace" || name === "destroyworkspacev2") {
        var destroyedFields = event.parse(name === "destroyworkspacev2" ? 2 : 1)
        var destroyedWorkspaceId = Number(destroyedFields[0])
        if (isFinite(destroyedWorkspaceId) && destroyedWorkspaceId > 0)
          root.forgetMovedWorkspace(destroyedWorkspaceId)
      } else if (name === "monitoradded" || name === "monitoraddedv2" ||
                 name === "monitorremoved" || name === "monitorremovedv2" ||
                 name === "configreloaded") {
        workspaceMoveRefresh.restart()
      }
    }
  }

  Timer {
    id: workspaceMoveRefresh
    interval: 0
    repeat: false
    onTriggered: {
      Hyprland.refreshMonitors()
      Hyprland.refreshWorkspaces()
    }
  }

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null &&
          Hyprland.focusedWorkspace.id === modelData
        readonly property bool associated: root.workspaceMonitorName(modelData) === root.screenName

        bar: root.bar
        active: root.extendedDesktop && associated
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || associated ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
