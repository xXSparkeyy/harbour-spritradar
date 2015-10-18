import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    height: opText.paintedHeight+Theme.paddingSmall*2
    width: parent.width
    property alias title: opText.text
    property alias text : opTime.text
    Text {
        id: opText
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: Theme.paddingSmall
        width: paintedWidth
        x: 0
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
    }
    Label {
        id: opTime
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: opText.right
        anchors.right: parent.right
        anchors.margins: Theme.paddingSmall
        x: width
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
    }
}
