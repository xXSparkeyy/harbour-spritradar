import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string name: ""
    property variant price: 0
    property string address: ""
    property string distance: ""
    property string stId: ""

    Rectangle {
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: img
            anchors {
                topMargin: -1 * Theme.paddingSmall
                left: parent.left
                top: parent.top
            }
            color: Theme.highlightColor
            text: price
            font.pixelSize: Theme.fontSizeExtraLarge
        }
        Label {
            id: nm
            anchors {
                leftMargin: Theme.paddingMedium
                right: parent.right
                left: img.right
                top: parent.top
            }
            height: paintedHeight
            color: down ? Theme.highlightColor : Theme.primaryColor
            text: name
            font.pixelSize: Theme.fontSizeMedium
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: srt
            anchors {
                topMargin: -1 * Theme.paddingSmall
                leftMargin: Theme.paddingMedium
                right: parent.right
                left: img.right
                top: nm.bottom
            }
            height: paintedHeight
            color: down ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: (isFav( stId )?"★":"☆")+" "+distance+"km | "+address
            truncationMode: TruncationMode.Fade
        }
    }
}
