import QtQuick
import QtQuick.Controls as Controls
import ".."

Item {
  id: row
  required property var hub
  required property string modeId
  required property string caption
  required property url nativeSource
  property bool available: true
  property string unavailableReason: "Unavailable"
  property bool closeOnActivate: false
  readonly property var control: nativeLoader.item
  readonly property var nativeButton: findButton(control)
  readonly property bool ready: available && nativeButton !== null && (modeId !== "Microphone" || (control && control.source !== null))
  readonly property bool active: control ? (modeId === "Microphone" ? control.inUse : control.active) : false
  readonly property string hint: !ready ? unavailableReason : (nativeButton ? nativeButton.tooltipText : "")
  readonly property string stateText: {
    if (!ready) return "Unavailable"
    if (modeId === "Microphone") return control.muted ? "Muted" : (control.inUse ? "In use" : "Ready")
    if (modeId === "Reminder") return control.reminderCount > 0 ? String(control.reminderCount) : "None"
    if (modeId === "Dictation") return control.state === "idle" ? "Ready" : control.state
    return active ? "On" : "Off"
  }
  implicitHeight: 36

  function findButton(item) {
    if (!item) return null
    if (typeof item.triggerPress === "function") return item
    for (var i = 0; i < item.children.length; i++) {
      var result = findButton(item.children[i])
      if (result) return result
    }
    return null
  }

  function inject() {
    var item = control
    if (!item) return
    item.bar = hub.bar
    if ("indicatorHost" in item) item.indicatorHost = hub
    if ("indicatorBlock" in item) item.indicatorBlock = "single"
  }

  function activate(button) {
    if (!ready) return
    if (closeOnActivate) hub.close()
    nativeButton.triggerPress(button)
  }

  Connections {
    target: row.hub
    function onBarChanged() { row.inject() }
  }

  Rectangle {
    anchors.fill: parent
    color: pointer.containsMouse && row.ready ? Theme.badge : "transparent"
    radius: 3
  }

  Loader {
    id: nativeLoader
    x: 5
    width: 27
    height: 26
    anchors.verticalCenter: parent.verticalCenter
    source: row.nativeSource
    opacity: row.modeId === "Microphone" && !row.active ? 0.45 : 1
    onLoaded: row.inject()
  }

  Text {
    x: 42
    anchors.verticalCenter: parent.verticalCenter
    text: row.caption
    color: row.ready ? Theme.accent : Theme.muted
    opacity: row.ready ? 1 : 0.55
    font.family: row.hub.bar ? row.hub.bar.fontFamily : "monospace"
    font.pixelSize: 12
  }

  Text {
    anchors.right: parent.right
    anchors.rightMargin: 9
    anchors.verticalCenter: parent.verticalCenter
    text: row.stateText
    color: row.active ? Theme.accent : Theme.muted
    opacity: row.active ? 1 : 0.7
    font.family: row.hub.bar ? row.hub.bar.fontFamily : "monospace"
    font.pixelSize: 10
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: row.ready ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: function(mouse) { row.activate(mouse.button) }
    onWheel: function(wheel) {
      if (row.ready && row.nativeButton) row.nativeButton.wheelMoved(wheel.angleDelta.y)
    }
  }

  Controls.ToolTip {
    parent: row
    visible: pointer.containsMouse && row.hint !== ""
    delay: 450
    text: row.hint
    contentItem: Text {
      text: row.hint
      color: Theme.accent
      font.family: row.hub.bar ? row.hub.bar.fontFamily : "monospace"
      font.pixelSize: 10
    }
    background: Rectangle { color: Theme.background; border.color: Theme.border; radius: 2 }
  }
}
