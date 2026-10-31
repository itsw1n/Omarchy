import QtQuick
import QtQuick.Shapes
import ".."

Item {
  id: panel
  property color fillColor: Theme.segment
  property color lineColor: Theme.border
  property real leftSkew: 0
  property real rightSkew: 0
  property bool capLeft: false
  property bool capRight: false
  property bool embedded: false
  property bool accentLeft: !embedded
  property bool divideLeft: false
  property bool divideRight: embedded
  property bool hideRightEdge: false
  readonly property real lc: capLeft ? 4 : 0
  readonly property real rc: capRight ? 4 : 0

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    // A single outer frame. Inset module faces omit its horizontal outline.
    ShapePath {
      strokeColor: panel.embedded || panel.hideRightEdge ? "transparent" : panel.lineColor
      strokeWidth: 0.8
      fillColor: panel.embedded || panel.hideRightEdge ? panel.fillColor : Theme.backing
      joinStyle: ShapePath.MiterJoin
      startX: panel.lc + 0.5; startY: 0.5
      PathLine { x: panel.width - panel.rc - 0.5; y: 0.5 }
      PathLine { x: panel.width - 0.5; y: panel.rc + 0.5 }
      PathLine { x: panel.width + panel.rightSkew - 0.5; y: panel.height - panel.rc - 0.5 }
      PathLine { x: panel.width + panel.rightSkew - panel.rc - 0.5; y: panel.height - 0.5 }
      PathLine { x: panel.leftSkew + panel.lc + 0.5; y: panel.height - 0.5 }
      PathLine { x: panel.leftSkew + 0.5; y: panel.height - panel.lc - 0.5 }
      PathLine { x: 0.5; y: panel.lc + 0.5 }
      PathLine { x: panel.lc + 0.5; y: 0.5 }
    }
    ShapePath {
      strokeColor: panel.hideRightEdge ? panel.lineColor : "transparent"
      strokeWidth: 0.8
      fillColor: "transparent"
      startX: panel.lc + 0.5; startY: 0.5
      PathLine { x: panel.width - panel.rc - 0.5; y: 0.5 }
    }
    ShapePath {
      strokeColor: panel.hideRightEdge ? panel.lineColor : "transparent"
      strokeWidth: 0.8
      fillColor: "transparent"
      startX: panel.leftSkew + panel.lc + 0.5; startY: panel.height - 0.5
      PathLine { x: panel.width + panel.rightSkew - panel.rc - 0.5; y: panel.height - 0.5 }
    }
    ShapePath {
      strokeColor: "transparent"
      fillColor: panel.fillColor
      startX: panel.lc + 3; startY: 3
      PathLine { x: panel.width - panel.rc - 3; y: 3 }
      PathLine { x: panel.width - 3; y: panel.rc + 3 }
      PathLine { x: panel.width + panel.rightSkew - 3; y: panel.height - panel.rc - 3 }
      PathLine { x: panel.width + panel.rightSkew - panel.rc - 3; y: panel.height - 3 }
      PathLine { x: panel.leftSkew + panel.lc + 3; y: panel.height - 3 }
      PathLine { x: panel.leftSkew + 3; y: panel.height - panel.lc - 3 }
      PathLine { x: 3; y: panel.lc + 3 }
      PathLine { x: panel.lc + 3; y: 3 }
    }
    // Short upper bevel; the rest of the surface remains flat graphite.
    ShapePath {
      strokeColor: "transparent"
      fillColor: Theme.bevel
      startX: panel.lc + 1; startY: 1
      PathLine { x: panel.width - panel.rc - 1; y: 1 }
      PathLine { x: panel.width - panel.rc - 4; y: 2.5 }
      PathLine { x: panel.lc + 4; y: 2.5 }
      PathLine { x: panel.lc + 1; y: 1 }
    }
    ShapePath {
      strokeColor: panel.accentLeft ? Theme.edgeAccent : "transparent"
      strokeWidth: 0.7
      fillColor: "transparent"
      startX: panel.capLeft ? 4.5 : 0.5; startY: 0.5
      PathLine { x: panel.capLeft ? 0.5 : panel.leftSkew * 0.7 + 0.5; y: panel.capLeft ? 4.5 : panel.height * 0.7 }
    }
    ShapePath {
      strokeColor: panel.divideLeft ? Theme.border : "transparent"
      strokeWidth: 0.8
      fillColor: "transparent"
      startX: 0.5; startY: 0.5
      PathLine { x: panel.leftSkew + 0.5; y: panel.height - 0.5 }
    }
    ShapePath {
      strokeColor: panel.divideRight ? Theme.border : "transparent"
      strokeWidth: 0.8
      fillColor: "transparent"
      startX: panel.width - 0.5; startY: 0.5
      PathLine { x: panel.width + panel.rightSkew - 0.5; y: panel.height - 0.5 }
    }
  }
}
