import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import harbour.spritradar.Settings 1.0
import "pages"

ApplicationWindow
{
    id: main
    initialPage: favs
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

   PositionSource {
        id: position
        active: useGps
   }


   ContextMenu {
       id: favMenu
       property variant parentItem;
       function _showI( anchor, item ) {
           parentItem = item
           show( anchor )
       }

       MenuItem {
           text: ( isFav( favMenu.parentItem.stId ) ? qsTr( "Unset as Favourite" ) : qsTr( "Set as Favourite" ) )
           onClicked: ( isFav( favMenu.parentItem.stId ) ? unsetFav : setFav )(favMenu.parentItem.stId , favMenu.parentItem.name)
       }
   }
    Settings {
        id: settings
        Component.onCompleted: {
            load()
        }


        function save() {
            setValue( "radius", searchRadius )
            setValue( "type", type )
            setValue( "sort", sort )
            setValue( "gps", useGps )
            setValue( "zipCode", zipCode )
        }
        function load() {
            searchRadius = getValue( "radius" )
            type = getValue( "type" )
            sort = getValue( "sort" )
            useGps = eval( getValue( "gps" ) )
            zipCode = getValue( "zipCode" )
            favs.load()
        }
    }
    property string apikey: tankerkoenig_apikey
    property alias searchRadius: conf.searchRadius //0-25
    property string type: "e10" //e5,e10,diesel
    property string sort: "price" //price,dist
    property alias useGps: conf.useGps
    property alias zipCode: conf.zipCode
    property string latitude: position.position.coordinate.latitude
    property string longitude: position.position.coordinate.longitude
    property variant searchItems: []
    property bool loading: false
    property variant favs: []
    property variant station: []
    property bool stationLoading: false
    List { id: list }
    Config { id: conf }
    Favs { id: favs }
    function isFav(x) {return favs.is( x )}
    function setFav(x,y) {favs.set(x,y) }
    function unsetFav(x,y) {favs.unset(x,y)}
    Component.onCompleted: {
        pageStack.pushAttached( list )
        pageStack.push( list, PageStackAction.Immediate)
        search()
    }
    Component.onDestruction: {
        settings.save()
    }
    onSortChanged: {
        searchItems = qmSort( searchItems, "asc" )
    }

    function qmSort( list, mode ) {
        if( list.length > 1 ) {
            var left = []
            var right = []
            var pivot =  list[list.length-1]
            var srt = sort == "dist"
            for( var i = 0; i < list.length-1; i++ ) {
                var itm = list[i]
                if( ( (srt?itm.dist:itm.price) < (srt?pivot.dist:pivot.price) && mode == "asc" ) || ( (srt?itm.dist:itm.price) > (srt?pivot.dist:pivot.price) && mode == "desc" ) ) {
                    left[left.length] = list[i]
                }
                else {
                    right[right.length] = list[i]
                }
            }
            left = qmSort( left, mode )
            right = qmSort( right, mode )
            list = ( left.concat( [pivot] ) ).concat( right )
        }
        return list
    }

    function search() {
        //pageStack.push( list )
        searchItems = ""
        loading = true
        if( useGps ) {
            _serach( latitude, longitude )
        }
        else {
            var req = new XMLHttpRequest()
            req.open( "GET", "http://maps.google.com/maps/api/geocode/json?components=country:DE|postal_code:"+zipCode )
            req.onreadystatechange = function() {
                if( req.readyState == 4 ) {
                    try {
                        var x = eval( req.responseText ).results[0].geometry.location
                        _serach( x.lat, x.lng )
                    }
                    catch( e ) {
                        loading = false
                        list.errorCode = 2
                    }
                }
            }
            req.send()
        }

    }

    function _serach( lat, lng ) {
        var req = new XMLHttpRequest()
        req.open( "GET", "https://creativecommons.tankerkoenig.de/json/list.php?lat="+lat+"&lng="+lng+"&rad="+searchRadius+"&sort="+sort+"&type="+type+"&apikey="+apikey )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    list.errorCode = 0
                    var x = eval( req.responseText )
                    searchItems = x.stations
                    loading = false
                    list.errorCode = searchItems == 0 ? 1 : 0
                }
                catch ( e ) {
                    list.errorCode = 1
                }
            }
        }
        req.send()
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
}
