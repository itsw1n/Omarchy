import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import ".."

Item {
  id: controlHub
  required property Item anchorItem
  required property QtObject bar
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property bool opened: false
  property bool voxtypeAvailable: false
  property bool recorderAvailable: false
  readonly property bool revealInactiveIndicators: true
  readonly property var modeRows: [microphone, awake, dnd, nightlight, recording, dictation, reminder]
  readonly property bool recordingActive: recording.active
  readonly property bool microphoneActive: microphone.active
  implicitWidth: anchorItem ? anchorItem.width : 68
  implicitHeight: Theme.badgeHeight

  function nativeIndicator(name) {
    return "file://" + omarchyPath + "/shell/plugins/bar/indicators/" + name + ".qml"
  }

  function refresh() {
    for (var i = 0; i < modeRows.length; i++) {
      var control = modeRows[i].control
      if (control && typeof control.refresh === "function") control.refresh()
    }
  }

  function open() {
    if (bar && typeof bar.requestPopout === "function") bar.requestPopout(controlHub)
    if (bar && typeof bar.refreshIndicators === "function") bar.refreshIndicators()
    refresh()
    opened = true
    Qt.callLater(function() { content.forceActiveFocus() })
  }
  function close() { opened = false }
  function toggle() { if (opened) close(); else open() }

  Component.onDestruction: if (bar && bar.activePopout === controlHub) bar.releasePopout(controlHub)

  Process {
    command: ["bash", "-c", "for tool in voxtype gpu-screen-recorder; do command -v \"$tool\" >/dev/null && printf '%s\\n' \"$tool\"; done"]
    running: true
    stdout: SplitParser {
      onRead: function(tool) {
        if (tool.trim() === "voxtype") controlHub.voxtypeAvailable = true
        if (tool.trim() === "gpu-screen-recorder") controlHub.recorderAvailable = true
      }
    }
  }

  WidgetButton {
    anchors.fill: parent
    bar: controlHub.bar
    labelVisible: false
    hasVisualContent: true
    tooltipText: "Arch Control Hub"
    onPressed: controlHub.toggle()
  }

  // Privacy status occupies an overlay, never a slot in the bar's main row.
  Row {
    x: controlHub.width + 2
    anchors.verticalCenter: parent.verticalCenter
    BarIconButton {
      visible: controlHub.recordingActive
      bar: controlHub.bar
      text: recording.control ? recording.control.activeText : ""
      slotSize: 18
      opticalSize: 13
      active: true
      tooltipText: "Recording in progress — click to stop"
      onPressed: recording.activate(Qt.LeftButton)
    }
    BarIconButton {
      visible: controlHub.microphoneActive
      bar: controlHub.bar
      text: "󰍬"
      slotSize: 18
      opticalSize: 13
      active: true
      tooltipText: "Microphone in use — open controls"
      onPressed: controlHub.open()
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: controlHub.anchorItem
    bar: controlHub.bar
    owner: controlHub
    open: controlHub.opened
    centerOnBar: false
    margin: 2
    gap: 2
    padding: 10
    borderSpec: Border.flat(Theme.border, 1)
    contentWidth: 300
    contentHeight: fittedContentHeight(column.implicitHeight)
    focusTarget: content

    FocusScope {
      id: content
      anchors.fill: parent
      opacity: controlHub.opened ? 1 : 0
      focus: controlHub.opened
      Keys.onEscapePressed: function(event) { controlHub.close(); event.accepted = true }
      transform: Translate {
        y: controlHub.opened ? 0 : -6
        Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
      }
      Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

      Column {
        id: column
        width: parent.width
        spacing: 2
        Item {
          width: parent.width
          height: 32
          Text {
            anchors.left: parent.left
            anchors.leftMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            text: "ARCH CONTROL HUB"
            color: Theme.accent
            font.family: controlHub.bar.fontFamily
            font.pixelSize: 11
            font.letterSpacing: 0.5
          }
          Item {
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            Text { anchors.centerIn: parent; text: "×"; color: Theme.muted; font.pixelSize: 18 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: controlHub.close() }
          }
        }

        HubControlRow {
          id: microphone
          hub: controlHub
          width: parent.width
          modeId: "Microphone"
          caption: "Microphone"
          nativeSource: "file://" + controlHub.omarchyPath + "/shell/plugins/bar/widgets/Microphone.qml"
          unavailableReason: "No microphone input is available"
        }
        HubControlRow {
          id: awake
          hub: controlHub
          width: parent.width
          modeId: "StayAwake"
          caption: "Stay Awake"
          nativeSource: controlHub.nativeIndicator(modeId)
        }
        HubControlRow {
          id: dnd
          hub: controlHub
          width: parent.width
          modeId: "Dnd"
          caption: "Do Not Disturb"
          nativeSource: controlHub.nativeIndicator(modeId)
        }
        HubControlRow {
          id: nightlight
          hub: controlHub
          width: parent.width
          modeId: "NightLight"
          caption: "Night Light"
          nativeSource: controlHub.nativeIndicator(modeId)
        }
        HubControlRow {
          id: recording
          hub: controlHub
          width: parent.width
          modeId: "ScreenRecording"
          caption: "Screen Recording"
          nativeSource: controlHub.nativeIndicator(modeId)
          available: controlHub.recorderAvailable
          unavailableReason: "gpu-screen-recorder is not installed"
          closeOnActivate: true
        }
        HubControlRow {
          id: dictation
          hub: controlHub
          width: parent.width
          modeId: "Dictation"
          caption: "Dictation"
          nativeSource: controlHub.nativeIndicator(modeId)
          available: controlHub.voxtypeAvailable
          unavailableReason: "Voxtype is not installed"
          closeOnActivate: true
        }
        HubControlRow {
          id: reminder
          hub: controlHub
          width: parent.width
          modeId: "Reminder"
          caption: "Reminders"
          nativeSource: controlHub.nativeIndicator(modeId)
          closeOnActivate: true
        }

        Rectangle { width: parent.width; height: 1; color: Theme.badgeRidge }
        WidgetButton {
          width: parent.width
          bar: controlHub.bar
          text: "󰤄  System menu"
          fontSize: 11
          tooltipText: "Lock, suspend, restart, or shut down"
          onPressed: { controlHub.close(); controlHub.bar.run("omarchy-menu summon system") }
        }
      }
    }
  }
}
