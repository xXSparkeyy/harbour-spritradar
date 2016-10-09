import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    clip: true
    allowedOrientations: Orientation.All
    property variant stations: []
    function set( stId, name ) {
        var y = stations
        y[y.length] = { id:stId, name:name, price:9.999 }
        stations = y
        save()
        selectedPlugin.getPriceForFav(stId)
    }
    function unset( stId, name ) {
        var y = []
        for( var i = 0; i<stations.length; i++ ) {
            if( stations[i].id != stId ) y[y.length] = stations[i]
        }
        stations = y
        save()
    }
    function is( stId ) {
        for( var i = 0; i<stations.length; i++ ) {
            if( stId == stations[i].id ) return true
        }
        return false
    }
    function load() {
        var y = []
        var x = selectedPlugin.settings.getValue( "Favourites/count" )
        for( var i = 0; i<x; i++ ) {
            var s = selectedPlugin.settings.getValue( "Favourites/station"+i ).split("|")
            y[y.length] = { id:s[0], name:s[1], price:9.999}
            selectedPlugin.getPriceForFav( s[0] )
        }
        stations = y
    }
    function save() {
        selectedPlugin.settings.setValue( "Favourites/count", stations.length )
        for( var i = 0; i<stations.length; i++ ) {
            selectedPlugin.settings.setValue( "Favourites/station"+i, stations[i].id+"|"+stations[i].name )
        }
    }
    SilicaFlickable {
        contentHeight: col.height
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                enabled: main.launchToList
                text: qsTr("Set as First Page")
                onClicked: launchToList = false
            }
            MenuItem {
                enabled: main.launchToList
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
                model: stations.length
                    StationListDelegate {
                        id: lavkavk
                        width: col.width
                        name: stations[index].name
                        price: stations[index].price
                        property string stId: stations[index].id
                        onClicked: {
                            selectedPlugin.requestStation( stations[index].id )
                        }
                        height: Theme.itemSizeSmall + ( favMenu.parentItem == lavkavk ? favMenu.height : 0 )
                        onPressAndHold: favMenu._showI( this, lavkavk )
                }
            }
        }
    }
}
