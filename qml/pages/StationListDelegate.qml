import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string name: ""
    property variant price: 0
    property string street: ""
    property string distance: ""
    property string stId: ""
        Text {
            id: img
            anchors.margins: Theme.paddingSmall
            anchors.left: parent.left
            anchors.top: parent.top
            color: Theme.highlightColor
            text: price
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeExtraLarge
        }

        Label {
            id: nm
            anchors.margins: Theme.paddingMedium
            anchors.right: parent.right
            anchors.left: img.right
            anchors.top: parent.top
            height: paintedHeight
            color: down ? Theme.highlightColor : Theme.primaryColor
            text: name
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeMedium
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: srt
            anchors.margins: Theme.paddingMedium
            anchors.topMargin: -1*Theme.paddingMedium
            anchors.right: parent.right
            anchors.left: img.right
            height: paintedHeight
            anchors.top: nm.bottom
            color: down ? Theme.secondaryHighlightColor : Theme.secondaryColor
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeSmall
            text: (isFav( stId )?"★":"☆")+" ~"+distance+"km | "+street
            truncationMode: TruncationMode.Fade
        }
}
