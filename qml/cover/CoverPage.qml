import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

CoverBackground {
    property bool sourceFromList: !favsOnCover
    property ListModel source: sourceFromList ? selectedPlugin.coverItems : favs.stations
    CoverPlaceholder {
        visible: ( selectedPlugin.coverItems.count < 1 ) && !selectedPlugin.itemsBusy && selectedPlugin.pluginReady
        text: qsTr( "Nothing Found" )
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
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
            anchors.fill: parent
            Repeater {
                id: listView
                model: source
                delegate: ListText {
                    width: cover.width
                    text:      stationName
                    title:     normalizePrice(stationPrice).join("")
                    leftAlign: true
                }
            }
        }

    }
    BusyIndicator  {
        anchors.centerIn: parent
        running: true
        visible: selectedPlugin.itemsBusy || !selectedPlugin.pluginReady
    }
    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered:  launchToList ? selectedPlugin.requestItems() : favs.load()
        }
        CoverAction {
            iconSource: sourceFromList ? "image://theme/icon-cover-search" : "image://theme/icon-cover-favorite"
            onTriggered:  sourceFromList = !sourceFromList
        }
    }
}


