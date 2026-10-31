import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui
import ".."

Item {
  id: root

  property var bar: null
  property int windowSize: 5
  readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function visibleIds() {
    var ids = []
    var active = activeId

    if (active <= 0 || active <= windowSize) {
      for (var i = 1; i <= windowSize; i++) ids.push(i)
      return ids
    }

    for (var j = active - windowSize + 1; j <= active; j++) ids.push(j)
    return ids
  }

  function focusWorkspace(id) {
    if (!bar) return
    bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  implicitWidth: grid.implicitWidth
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    columns: root.windowSize
    columnSpacing: Style.space(1)

    Repeater {
      model: root.visibleIds()

      Item {
        id: cell
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: root.activeId === modelData

        implicitWidth: Style.space(22)
        implicitHeight: root.bar ? root.bar.barSize : Style.bar.sizeHorizontal

        Rectangle {
          width: Style.space(11)
          height: Style.space(11)
          anchors.centerIn: parent
          radius: Style.space(3)
          color: root.bar ? root.bar.barForeground : Theme.wing
          visible: cell.focused
        }

        WidgetButton {
          anchors.fill: parent
          bar: root.bar
          text: String(cell.modelData)
          labelVisible: !cell.focused
          active: cell.focused
          activeColor: root.bar ? root.bar.background : "#0b1220"
          dimmed: !cell.occupied && !cell.focused
          onPressed: function() { root.focusWorkspace(cell.modelData) }
        }
      }
    }
  }
}
