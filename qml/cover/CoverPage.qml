import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Item {
        id: cover
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: coverAction.top
            margins: Theme.paddingSmall * 2
        }

        Column {
            width: parent.width
            Repeater {
                model: searchItems.length > 5 ? 5 : searchItems.length
                Item {
                    height: price.paintedHeight * 1.5
                    width: cover.width
                    Label {
                        id: price
                        text: searchItems[index].price
                        color: Theme.highlightColor
                        anchors.left: parent.left
                    }
                    Label {
                        text: searchItems[index].brand !== "" ? searchItems[index].brand : searchItems[index].name
                        color: Theme.primaryColor
                        anchors {
                            left: price.right
                            right: parent.right
                            top: price.top
                            leftMargin: Theme.paddingSmall
                        }
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        width: parent.width
                        text: capitalizeString(searchItems[index].street) + (typeof(searchItems[index].houseNumber) == "object" ? "" : " " + searchItems[index].houseNumber) + ", " + searchItems[index].postCode + " " + capitalizeString(searchItems[index].place)
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: price.bottom
                            topMargin: -1 * Theme.paddingSmall
                        }
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


