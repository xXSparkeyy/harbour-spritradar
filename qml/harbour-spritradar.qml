import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.spritradar.Util 1.0
import "pages"
import "pages/Plugin"

ApplicationWindow
{
    id: main
    initialPage: favs
    Component.onCompleted: {
        pluginSettings.load();
        pageStack.pushAttached( list )
        if( launchToList ) pageStack.push( list, PageStackAction.Immediate)
        else if( !selectedPlugin.pluginReady ) { selectedPlugin.prepare() }
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

    property string sort: "price" //price,dist


    property string latitude: position.position.coordinate.latitude
    property string longitude: position.position.coordinate.longitude
    property variant searchItems: []
    property bool loading: false
    property variant favs: []
    property variant station: []
    property bool stationLoading: false
    property bool launchToList: true
    onLaunchToListChanged: pluginSettings.save()
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
                    case tk.name: selectedPlugin = tk; selectedPluginNum = 0; break
                    case sv.name: selectedPlugin = sv; selectedPluginNum = 1; break
                    case gg.name: selectedPlugin = gg; selectedPluginNum = 2;break
                    case gf.name: selectedPlugin = gf; selectedPluginNum = 4;break
                    default: selectedPlugin = tk;
                }
                launchToList = getValue( "launchToList" )==1
            }
            catch( e ) {
                assign()
            }
        }
        function save() {
            setValue( "plugin", selectedPlugin.name )
            setValue( "launchToList", launchToList?"1":"0" )
        }
        function assign() {
            selectedPlugin = tk
            launchToList = true
            save()
        }
    }
    property Plugin selectedPlugin;
    TankerKoenig { id: tk }
    Sviluppoeconomico { id: sv }
    GeoportalGasolineras { id: gg }
    MyGasFeed { id: gf }
    function changePlugin( plugin ) {
        plugin.pluginReady = false
        selectedPlugin.station = {}
        selectedPlugin.items.clear()
        selectedPlugin = plugin
        pluginSettings.save()
        pageStack.popAttached()
    }

    property int selectedPluginNum: 0
    property ContextMenu pluginSwitcher: ContextMenu {
        id: plgnswtchr
        MenuItem {
            text: tk.name
            onClicked: { changePlugin( tk ); selectedPluginNum = 0 }
        }
        MenuItem {
            text: sv.name
            onClicked: { changePlugin( sv ); selectedPluginNum = 1 }
        }
        MenuItem {
            text: gg.name
            onClicked: { changePlugin( gg ); selectedPluginNum = 2 }
        }
        MenuItem {
            text: gf.name
            onClicked: { changePlugin( gf ); selectedPluginNum = 3 }
        }
    }

    property bool gpsActive: false


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
    function normalizePrice( p ) {
        p = (p<1?"0":"")+(p<0.1?"0":"")+(p*1000)

        var ret = p.charAt( 0 )+"."
        for( var i = 1; i<3; i++ ) { ret+=(p.charAt(i)?p.charAt(i):"0") }
        var supPrice = p.charAt(3)?p.charAt(i):"0"
        return [ret,supPrice]
    }
    function getTimestamp( year, month, day, hour, minute, second ) {
        var months = [31,28,31,30,31,30,31,31,30,31,30,31]
        for( var i = 0; i < month; i++ ) { day+=months[i] }    // Monate zu Tagen
        if( (year-1972)%4 == 0 ) day+=1                        // Schaltjahre
        return ((((year-1970)*365+day)*12+hour)*60+minute)*60  // Alles runter gerechnet bis Sekunden, Millisekunden *ergeben* keinen Sinn
    }

    function getGeoDistance( lat1, lng1, lat2, lng2) {
            var R = 6371000;
            var a1 = lat1/180*Math.PI
            var o1 = lng1/180*Math.PI
            var a2 = lat2/180*Math.PI
            var o2 = lng2/180*Math.PI
            var da = a2 - a1;
            var db = o2 - o1;
            var a = Math.sin(da/2) * Math.sin(da/2)
                  + Math.cos(a1) * Math.cos(a2)
                  * Math.sin(db/2) * Math.sin(db/2);
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            var d = Math.round(R * c)
            return d;
    }


}
