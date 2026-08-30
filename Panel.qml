import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "io.github.ejames-dev.honcho"
  ipcTarget: "io.github.ejames-dev.honcho"

  property var anchorItem: null
  property var hostWidget: null
  readonly property string helperPath: Qt.resolvedUrl("bin/omarchy-honcho").toString().replace(/^file:\/\//, "")
  property var status: Model.emptyStatus()
  property bool loaded: false
  readonly property bool isAlert: loaded && !status.reachable
  readonly property string label: Model.pillText(status)
  readonly property string tooltip: Model.tooltipText(loaded ? status : null)

  function refresh() {
    if (!poller.running) poller.running = true
  }

  onOpenedChanged: if (opened) refresh()

  Process {
    id: poller
    command: [root.helperPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.status = Model.parseStatus(text)
        root.loaded = true
      }
    }
  }

  Timer {
    // Keeps the bar pill current even while the panel is closed.
    interval: 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: contentColumn
        width: parent.width
        spacing: Style.space(10)

        PanelHero {
          title: "Honcho"
          meta: root.loaded ? (root.status.reachable ? "Connected" : "Not reachable") : "Checking…"
          foreground: root.bar ? root.bar.foreground : Color.foreground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          iconComponent: Component {
            Rectangle {
              width: Style.space(14)
              height: Style.space(14)
              radius: width / 2
              anchors.verticalCenter: parent.verticalCenter
              color: root.loaded && root.status.reachable ? "#5fd68a" : (root.bar ? root.bar.urgent : Color.urgent)
              opacity: root.loaded ? 1.0 : 0.4
            }
          }
        }

        PanelSeparator { foreground: root.bar ? root.bar.foreground : Color.foreground }

        Column {
          width: parent.width
          spacing: Style.space(5)

          PanelSectionHeader {
            text: "CONNECTION"
            leftPadding: Style.space(16)
            foreground: root.bar ? root.bar.foreground : Color.foreground
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          }

          Text {
            width: parent.width - Style.space(32)
            anchors.left: parent.left
            anchors.leftMargin: Style.space(16)
            text: root.status.url || "http://localhost:8000"
            textFormat: Text.PlainText
            elide: Text.ElideMiddle
            color: root.bar ? root.bar.foreground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            width: parent.width - Style.space(32)
            anchors.left: parent.left
            anchors.leftMargin: Style.space(16)
            text: "Set OMARCHY_HONCHO_URL to point at a different host or port."
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: root.bar ? Qt.darker(root.bar.foreground, 1.3) : Color.muted
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }

        Item { width: 1; height: Style.space(6) }
      }
    }
  }
}
