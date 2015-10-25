import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    height: opTitle.paintedHeight+Theme.paddingSmall*2
    width: parent.width
    property alias title: opTitle.text
    property alias text : opText.text
    Text {
        id: opTitle
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: paintedWidth
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
    }
    Label {
        id: opText
        anchors {
            top: opTitle.top
            bottom: opTitle.bottom
            left: opTitle.right
            right: parent.right
            leftMargin: Theme.paddingSmall
        }
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: Theme.primaryColor
        font.pixelSize: 0
        truncationMode: TruncationMode.Fade
    }
}
