import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    clip: true
    id: page
    onStatusChanged: if( status == PageStatus.Active) { if( !selectedPlugin.pluginReady ) { selectedPlugin.prepare() }; pageStack.pushAttached( selectedPlugin ) }
    allowedOrientations: Orientation.All
    property int errorCode: 0
    canNavigateForward: selectedPlugin.pluginReady
    backNavigation: selectedPlugin.pluginReady && selectedPlugin.supportsFavs

    SilicaListView {
        id: listView
        model: selectedPlugin.items
        //onModelChanged: { for( var i = 0; i < model.count; i++ ) log( model.get(i) ) }
        interactive: !bsyi.visible
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Results")
        }
        delegate: StationListDelegate {
            id: lstItm
            width: parent.width
            name:      stationName
            price:     stationPrice
            distance:  stationDistance
            address:   stationAdress
            stId:      stationID
            message:   customMessage
            height: Theme.itemSizeSmall + ( favMenu.parentItem == this ? favMenu.height : 0 )
            onPressAndHold: if( selectedPlugin.supportsFavs ) favMenu._showI( this, this )
            onClicked: {
                selectedPlugin.requestStation( stId )
            }
        }
        PullDownMenu {
            busy: bsyi.visible
            MenuItem {
                enabled: !main.launchToList && selectedPlugin.supportsFavs
                text: qsTr("Set as First Page")
                onClicked: launchToList = true
            }
            MenuItem {
                text: qsTr("Sort by")+" "+(sort == "price"? qsTr("Distance"):qsTr("Price"))
                onClicked: sort = (sort == "price"?"dist":"price")
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: selectedPlugin.requestItems()
            }
        }

        VerticalScrollDecorator {}

        Label {
            id: plc
            visible: selectedPlugin.errorCode > 0 || !selectedPlugin.pluginReady
            text: selectedPlugin.pluginReady?selectedPlugin.errorCode == 1 ? qsTr( "Nothing Found" ) : selectedPlugin.errorCode == 2 ? qsTr( "Invalid zip code" ) : selectedPlugin.errorCode == 3 ? "Something went wrong":"":qsTr("Initializing")
            anchors.horizontalCenter: bsyi.horizontalCenter
            anchors.top: bsyi.bottom
            anchors.topMargin: Theme.paddingLarge
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
        BusyIndicator {
            id: bsyi
            anchors.centerIn: parent
            running: visible
            size: BusyIndicatorSize.Large
            visible: selectedPlugin.itemsBusy || !selectedPlugin.pluginReady
        }
    }

}
