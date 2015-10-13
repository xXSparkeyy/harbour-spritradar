import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Item {
        id: bla
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: coverAction.top
        anchors.margins: Theme.paddingSmall
        Column {
            width: bla.width
            Repeater {
                model: searchItems.length > 5 ? 5 : searchItems.length
                Item {
                    height: price.paintedHeight*1.5
                    y: height*index
                    width: bla.width
                    Text {
                        id: price
                        text: searchItems[index].price
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primaryColor
                        anchors.left: parent.left
                    }
                    Label {
                        text: searchItems[index].name
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                        anchors.left: price.right
                        anchors.right: parent.right
                        anchors.margins: Theme.paddingSmall
                        truncationMode: TruncationMode.Fade
                    }
                }
            }
        }

    }
    BusyIndicator  {
        anchors.centerIn: parent
        running: visible
        visible: loading
    }
    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: search()
        }
    }
}


