pragma Singleton
import QtQuick

QtObject {
  readonly property color background: "#03070c"
  readonly property color segment: "#080d15"
  readonly property color focusSegment: "#060b12"
  readonly property color backing: "#141e2c"
  readonly property color bevel: "#202d40"
  readonly property color badge: "#101a28"
  readonly property color badgeInner: "#050b13"
  readonly property color badgeRidge: "#23344b"
  readonly property color wing: "#8ca7d6"
  readonly property color wingShadow: "#121d30"
  readonly property color edgeAccent: "#8399b8"
  readonly property color border: "#46546b"
  readonly property color accent: "#afcaff"
  readonly property color muted: "#91a3bc"

  readonly property real barHeight: 32
  readonly property real segmentHeight: 26
  readonly property real badgeHeight: 32
  readonly property real badgeWing: 15
  readonly property real outerPadding: 8
  readonly property real connectionGap: 2

  function badgeWidth(screenWidth) {
    return Math.max(68, Math.min(110, Math.round(screenWidth * 0.05)))
  }

  function sectionWidth(screenWidth, role) {
    var remaining = screenWidth - outerPadding * 2 - connectionGap * 2 - badgeWidth(screenWidth)
    return Math.max(0, Math.round(remaining * ((role === "left" || role === "right") ? 0.32 : 0.18)))
  }
}
