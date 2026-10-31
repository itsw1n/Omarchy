import QtQuick
import QtQuick.Shapes
import ".."

Item {
  id: badge

  Item {
    id: body
    width: Math.min(badge.width, badge.height * 1.9)
    height: badge.height
    anchors.centerIn: parent
    readonly property real cut: height / 2 - 1

    PrismConnector { anchors.fill: parent; side: "left" }
    PrismConnector { anchors.fill: parent; side: "right" }

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeColor: Theme.border
        strokeWidth: 1
        fillColor: Theme.badgeInner
        joinStyle: ShapePath.MiterJoin
        startX: body.cut; startY: 0.5
        PathLine { x: body.width - body.cut; y: 0.5 }
        PathLine { x: body.width - 0.5; y: body.height / 2 }
        PathLine { x: body.width - body.cut; y: body.height - 0.5 }
        PathLine { x: body.cut; y: body.height - 0.5 }
        PathLine { x: 0.5; y: body.height / 2 }
        PathLine { x: body.cut; y: 0.5 }
      }
    }
    Image {
      width: Math.min(21, body.height * 0.66)
      height: Math.min(21, body.height * 0.66)
      anchors.centerIn: parent
      source: "../assets/arch.svg"
      sourceSize.width: 64
      sourceSize.height: 64
      fillMode: Image.PreserveAspectFit
      smooth: true
    }
  }
}
