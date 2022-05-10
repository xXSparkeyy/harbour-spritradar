import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    clip: true
    allowedOrientations: Orientation.All
    property ListModel stations: ListModel {}
    property ListModel stations_sorted: ListModel {}
    property bool reorder_mode: false
    onStationsChanged: sort()
    function set( stId, name ) {
        if( !selectedPlugin.supportsFavs ) return false
        stations.append( { id:stId, stationName:name, stationPrice:9.999 } )
        save()
        selectedPlugin.getPriceForFav(stId)
    }
    function unset( stId, name ) {
        if( !selectedPlugin.supportsFavs ) return false
        for( var i = 0; i<stations.count; i++ )
            if( stations.get(i).id == stId )
                stations.remove( i )

        save()
    }
    function is( stId ) {
        if( !selectedPlugin.supportsFavs ) return false
        for( var i = 0; i<stations.count; i++ ) {
            if( stId == stations.get(i).id ) return true
        }
        return false
    }
    function load() {
        if( !selectedPlugin.supportsFavs ) return false
        stations.clear()
        var x = selectedPlugin.settings.getValue( "Favourites/count" )
        for( var i = 0; i<x; i++ ) {
            var s = selectedPlugin.settings.getValue( "Favourites/station"+i ).split("|")
            stations.append( { id:s[0], stationName:s[1], stationPrice:9.999} )
            selectedPlugin.getPriceForFav( s[0] )
        }
    }
    function save() {
        if( !selectedPlugin.supportsFavs ) return false
        selectedPlugin.settings.setValue( "Favourites/count", stations.count )
        for( var i = 0; i<stations.count; i++ ) {
            selectedPlugin.settings.setValue( "Favourites/station"+i, stations.get(i).id+"|"+stations.get(i).stationName )
        }
    }
    function sort_favs() {
        var list = []
        for( var i = 0; i<stations.count; i++ ) {
            var o = stations.get(i)
            list[list.length] = {
                "id": o.id,
                "stationName": o.stationName,
                "stationPrice": o.stationPrice
            }
        }
        list = qmSort( "stationPrice", list )
        stations_sorted.clear()
        for( i = 0; i<list.length; i++ ) {
            stations_sorted.append(list[i])
        }
    }

    SilicaFlickable {
        contentHeight: col.height
        anchors.fill: parent

        VerticalScrollDecorator {}
        PullDownMenu {
            enabled: selectedPlugin.supportsFavs
            /*MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }*/
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                enabled: !favsOnCover
                text: qsTr("Set as Cover")
                onClicked: favsOnCover = true
            }
            MenuItem {
                enabled: main.launchToList
                text: qsTr("Set as First Page")
                onClicked: launchToList = false
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: load()
            }
        }

        PushUpMenu {
            enabled: selectedPlugin.supportsFavs
            MenuItem {
                text: qsTr("Sort by") + " " + (st_repr.model == stations ? qsTr("Price") : qsTr("Favourites"))
                onClicked: {
                    st_repr.model = st_repr.model == stations ? stations_sorted : stations
                    sort_favs()
                }
            }
            MenuItem {
                enabled: st_repr.model == stations
                text: reorder_mode ? "Save Order" : "Reorder"
                onClicked: {
                    if( reorder_mode ) save()
                    reorder_mode = !reorder_mode
                }
            }
        }

        Column {
            id: col
            width: parent.width
            PageHeader {
                title: qsTr("Favourites")
            }
            move: Transition {
                      NumberAnimation { properties: "x,y"; duration: 200 }
                  }
            Repeater {
                id: st_repr
                model: stations
                    StationListDelegate {
                        id: lavkavk
                        width: col.width
                        name: stationName
                        price: stationPrice
                        property string stId: id
                        onClicked: {
                            if(!reorder_mode) selectedPlugin.requestStation( id )
                        }
                        onNameChanged: stationName = name
                        height: Theme.itemSizeSmall + ( favMenu.parentItem == lavkavk ? favMenu.height : 0 )
                        onPressAndHold: favMenu._showI( this, lavkavk )
                        RemorseItem { id: remorse }
                        function del( stId, name ) {
                            remorse.execute( remorse_wrapper, "Deleting", function () { unset( stId, name ) })
                        }
                        Item {
                            id: remorse_wrapper
                            anchors.fill: parent
                        }
                        Item {
                            anchors.fill: parent
                            visible: reorder_mode
                            IconButton {
                               id: mvup_btn
                               icon.source: "image://theme/icon-m-up?" + (pressed? Theme.highlightColor: Theme.primaryColor)
                               onClicked: stations.move( index, index-1, 1 )
                               anchors.left: parent.left
                               anchors.verticalCenter: parent.verticalCenter
                           }
                           IconButton {
                               id: mvdw_btn
                               icon.source: "image://theme/icon-m-down?" + (pressed? Theme.highlightColor: Theme.primaryColor)
                               onClicked: stations.move( index, index+1, 1 )
                               anchors.left: mvup_btn.right
                               //anchors.margins: Theme.paddingSmall
                               anchors.verticalCenter: parent.verticalCenter
                           }
                        }
                    }
            }

        }
    }
    Label {
        id: plc
        visible: !selectedPlugin.supportsFavs
        text: "API doesn`t support this feature"
        anchors.centerIn: parent
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
    }
}
