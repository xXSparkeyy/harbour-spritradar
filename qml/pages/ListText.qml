import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    height: Math.max(opTitle.paintedHeight,opText.paintedHeight)+Theme.paddingSmall*2
    width: parent.width
    property alias title: opTitle.text
    property alias text : opText.text
    property bool titlefade: false
    property int size: Theme.fontSizeMedium
    property bool leftAlign: false
    Label {
        id: opTitle
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        property bool truncate: titlefade && opText.paintedWidth+paintedWidth > parent.width
        width: truncate?parent.width-(opText.paintedWidth+Theme.paddingSmall):paintedWidth
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: ""
        color: Theme.highlightColor
        font.pixelSize: size
        truncationMode: TruncationMode.Fade
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
        horizontalAlignment: opTitle.paintedWidth+paintedWidth>parent.width||leftAlign?Text.AlignLeft:Text.AlignRight
        verticalAlignment: Text.AlignVCenter

        text: ""
        color: Theme.primaryColor
        font.pixelSize: size
        truncationMode: TruncationMode.Fade
    }
}
