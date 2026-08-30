import QtQuick
import qs.Commons
import qs.Ui

// Bar host. Owns the bar slot and pill button; Panel.qml owns polling and
// the popup, mirroring the split used by other third-party plugins (e.g.
// io.github.jeremylongshore.foundry).
BarWidget {
  id: root
  moduleName: "io.github.ejames-dev.honcho"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.open) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  visible: true
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: panelLoader.item ? panelLoader.item.label : "Honcho"
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    active: panelLoader.item ? panelLoader.item.isAlert === true : false
    tooltipText: panelLoader.item ? panelLoader.item.tooltip : ""
    Accessible.role: Accessible.Button
    Accessible.name: panelLoader.item ? panelLoader.item.tooltip : "Open Honcho status"

    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }
}
