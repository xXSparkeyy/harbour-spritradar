import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.SpritRadar.Util 1.0
import "pages"
import "pages/Plugin"

ApplicationWindow
{
    id: main
    initialPage: favs
    Component.onCompleted: {
        pageStack.pushAttached( list )
        pageStack.push( list, PageStackAction.Immediate)
        selectedPlugin.requestItems
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    PositionSource {
         id: position
         active: gpsActive
    }

   ContextMenu {
       id: favMenu
       property variant parentItem;
       function _showI( anchor, item ) {
           parentItem = item
           show( anchor )
       }

       MenuItem {
           text: typeof favMenu.parentItem == "undefined"?"":( isFav( favMenu.parentItem.stId ) ? qsTr( "Unset as Favourite" ) : qsTr( "Set as Favourite" ) )
           onClicked: typeof favMenu.parentItem == "undefined"?"":( isFav( favMenu.parentItem.stId ) ? unsetFav : setFav )(favMenu.parentItem.stId , favMenu.parentItem.name)
       }
   }


    property string type: "e10" //e5,e10,diesel
    property string sort: "price" //price,dist


    property string latitude: position.position.coordinate.latitude
    property string longitude: position.position.coordinate.longitude
    property variant searchItems: []
    property bool loading: false
    property variant favs: []
    property variant station: []
    property bool stationLoading: false
    List { id: list }
    Favs { id: favs }
    function isFav(x) {return favs.is( x )}
    function setFav(x,y) {favs.set(x,y) }
    function unsetFav(x,y) {favs.unset(x,y)}


    Settings {
        id: pluginSettings
        function load() {
            try {
                switch( getValue( "plugin" ) ) {
                    case tk.name: selectedPlugin = tk; break
                    case sv.name: selectedPlugin = sv; break
                    default: selectedPlugin = tk
                }
            }
            catch( e ) {
                assign()
            }
        }
        function save() {
            setValue( "plugin", selectedPlugin.name )
        }
        function assign() {
            selectedPlugin = tk
            save()
        }
        Component.onCompleted: load()
    }
    property Plugin selectedPlugin;
    TankerKoenig { id: tk }
    Sviluppoeconomico { id: sv }
    function changePlugin( plugin ) {
        plugin.pluginReady = false
        selectedPlugin.station = {}
        selectedPlugin.items.clear()
        selectedPlugin = plugin
        pluginSettings.save()
        pageStack.popAttached()
    }



    property bool gpsActive: false

    Component.onDestruction: {
        settings.save()
    }
    onSortChanged: {
        selectedPlugin.settings.setValue( "sort", sort )
        selectedPlugin.sort()
    }

    function ucfirst(text) {
      text += '';
      var fChar = text.charAt(0).toUpperCase();
      return fChar + text.substr(1);
    }

    function capitalizeString(text) {
        var newText = text.toLowerCase()

        var textSplitDash = newText.split(" ")
        var newTextDash =""
        for (var i = 0; i < textSplitDash.length; i++) {
            newTextDash += ucfirst(textSplitDash[i]) + (i === textSplitDash.length - 1 ? "" : " ")
        }

        var textSplitHyphen = newTextDash.split("-")
        var newTextHyphen =""
        for (var i = 0; i < textSplitHyphen.length; i++) {
            newTextHyphen += ucfirst(textSplitHyphen[i]) + (i === textSplitHyphen.length - 1 ? "" : "-")
        }

        return newTextHyphen
    }

    function stripSeconds(time) {
        var timeSplitted = time.split(":")
        timeSplitted.splice(2,1)
        return timeSplitted.join(":")
    }
    function printlist( list, depth ) {
        var space="";for( var i = 0; i<depth;i++ ) space+="  "
        var pr = "{\n"
        depth = depth?depth:0
        for( var o in list ) {
            pr+= space
            if( typeof(list[o]) == "object" ) pr += "\""+o+"\": "+printlist( list[o], depth+1 )+",\n"
            else pr += "\""+o+"\": "+list[o]+",\n"
        }
        return pr.substring(0,pr.length-2)+"\n}"
    }
    function log( str ) {
        if( typeof(str) == "object" ) console.log( printlist( str ) )
        else console.log( str )
    }
}
