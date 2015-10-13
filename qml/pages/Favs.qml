import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    clip: true
    property variant stations: []
    function set( stId, name ) {
        var y = stations
        y[y.length] = { id:stId, name:name }
        stations = y
        save()
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
        var x = settings.getValue( "Favourites/count" )
        for( var i = 0; i<x; i++ ) {
            var s = settings.getValue( "Favourites/station"+i ).split("|")
            y[y.length] = { id:s[0], name:s[1] }
        }
        stations = y
    }
    function save() {
        settings.setValue( "Favourites/count", stations.length )
        for( var i = 0; i<stations.length; i++ ) {
            settings.setValue( "Favourites/station"+i, stations[i].id+"|"+stations[i].name )
        }
    }
    SilicaFlickable {
        contentHeight: col.height
        anchors.fill: parent
        VerticalScrollDecorator {}


       Column {
           id: col
           width: parent.width
           PageHeader {
               title: qsTr("Favourites")
           }

           Repeater {
                model: stations.length
                BackgroundItem {
                           width: parent.width
                           id: bghdfas
                           Label {
                                id: lavkavk
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: Theme.paddingLarge
                                text: stations[index].name
                                property string stId: stations[index].id
                                color: bghdfas.highlighted ? Theme.highlightColor : Theme.primaryColor
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                verticalAlignment: Text.AlignVCenter
                                truncationMode: TruncationMode.Fade

                           }
                           onClicked: {
                               pageStack.push( "GasStation.qml", { stationId:stations[index].id } )
                           }
                           height: Theme.itemSizeSmall + ( favMenu.parentItem == lavkavk ? favMenu.height : 0 )
                           onPressAndHold: favMenu._showI( this, lavkavk )
                       }
           }
       }
    }
}
