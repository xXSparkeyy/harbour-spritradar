import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    clip: true
    allowedOrientations: Orientation.All
    property ListModel stations: ListModel {}
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
        stations = y
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
    SilicaFlickable {
        contentHeight: col.height
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu {
            enabled: selectedPlugin.supportsFavs
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

        Column {
            id: col
            width: parent.width
            PageHeader {
                title: qsTr("Favourites")
            }

            Repeater {
                model: stations
                    StationListDelegate {
                        id: lavkavk
                        width: col.width
                        name: stationName
                        price: stationPrice
                        property string stId: id
                        onClicked: {
                            selectedPlugin.requestStation( id )
                        }
                        onNameChanged: stationName = name
                        height: Theme.itemSizeSmall + ( favMenu.parentItem == lavkavk ? favMenu.height : 0 )
                        onPressAndHold: favMenu._showI( this, lavkavk )
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
