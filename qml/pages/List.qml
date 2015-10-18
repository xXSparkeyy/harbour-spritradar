import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    clip: true
    id: page
    onStatusChanged: if( status == PageStatus.Active) { pageStack.pushAttached( conf ) }
    property int errorCode: 0
    SilicaListView {
        id: listView
        model: searchItems.length
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Results")
        }
        delegate: StationListDelegate {
            id: lstItm
            width: parent.width
            name: searchItems[index].name
            price: searchItems[index].price
            distance: searchItems[index].dist
            street: searchItems[index].street+(typeof(searchItems[index].houseNumber) == "object"?"":searchItems[index].houseNumber)+", "+searchItems[index].postCode+" "+searchItems[index].place
            stId: searchItems[index].id
            height: Theme.itemSizeSmall + ( favMenu.parentItem == this ? favMenu.height : 0 )
            onPressAndHold: favMenu._showI( this, this )
            onClicked: {
                pageStack.push( "GasStation.qml", { stationId:stId } )
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Sort by")+": "+(sort == "price"? qsTr("Price"):qsTr("Distance"))
                onClicked: sort = (sort == "price"?"dist":"price")
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: search()
            }
        }
        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: errorCode !== 0
            text: errorCode == 1 ? qsTr( "Nothing Found" ) : errorCode == 2 ? qsTr( "Invalid zip code" ) : ""
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: visible
        size: BusyIndicatorSize.Large
        visible: loading
    }
}
