import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

/*

  France: http://www.prix-carburants.gouv.fr/mobile/
  Spain: https://github.com/kbsali/gasolineras-espana/blob/master/open_gasolineras.py
  Netherlands: http://www.anwb.nl/pois/
  Österreich: www.spritpreisrechner.at ( Seems more like a developers diarrhea )


  Format for items:
    [
        ...,
        {
            "stationID": "",
            "stationName": "Cheaptank",
            "stationPrice": 1.111,
            "stationAdress": "Somestreet 1, 12345 Strangeville[, Country]",
            "stationDistance": 2.2,
        },
        ...
    ]
  Format for station
    {
        "stationID":"",
        "stationName":"",
        "stationAdress": {
            "street":"Somestreet 1",
            "county":"Strangeville",
            "country":"Country"
            "latitude":100.1210,
            "longitude":56.3432
        }
        "content": [
            {
                "title":"Prices"
                "items": [
                    ...
                    { "tile":"Gasoline", ["text":null, ]"price": 1.111 },
                    ...
                ]
            },
            {
                "title":"Info"
                "items": [
                    ...
                    { "tile":"State", "text":"Closed"[, "price":null] },
                    ...
                ]
            },
            ...
        ]
    }

*/
Dialog {
    id: page
    clip: true
    allowedOrientations: Orientation.All
    onStatusChanged: if( status === PageStatus.Deactivating) { if( doSearch) {doSearch = false; selectedPlugin.requestItems(); settings.save()} }
    onAccepted: doSearch = true
    acceptDestination: list
    acceptDestinationAction: PageStackAction.Pop

    property ListModel items: ListModel{}
    property ListModel coverItems: ListModel{}
    property variant station;
    property bool itemsBusy: false
    property bool stationBusy: false
    property int errorCode: 0
    property bool doSearch: false
    property bool pluginReady: false
    property Settings settings: Settings{}
    property Component content;
    property Page stationPage;
    property alias contentItem: contentWrapper.item
    property string name;
    property string description;
    property variant units: { "currency":"", "distance": "" }

    onPluginReadyChanged: if( pluginReady ) requestItems()

    function requestItems() {
        busy = true;
    }
    function requestStation( id ) {
        busy = true;
    }
    function prepare() {
        pluginReady = true
    }

    function sort() {
        var list = []
        for( var i = 0; i<items.count; i++ ) {
            var o = items.get(i)
            list[list.length] = {
                "stationID": o.stationID,
                "stationName": o.stationName,
                "stationPrice": o.stationPrice,
                "stationAdress": o.stationAdress,
                "stationDistance": o.stationDistance,
                "customMessage": o.customMessage
            }
        }
        if( main.sort!="price") list = qmSort( "price", list ).reverse()
        list = qmSort( main.sort, list )
        items.clear()
        for( var i = 0; i<list.length; i++ ) {
            items.append(list[i])
        }
        createCoverItems()
    }

    function createCoverItems() {
        coverItems.clear()
        for( var i = 0; i<items.count&&i<6; i++ ) {
            coverItems.append(items.get(i))
        }
    }

    function qmSort( by, list ) {
        if( list.length > 1 ) {
            var left = []
            var right = []
            var pivot =  list[list.length-1]
            var srt = by == "dist"
            for( var i = 0; i < list.length-1; i++ ) {
                var itm = list[i]
                if( ( (srt?itm.stationDistance:itm.stationPrice) < (srt?pivot.stationDistance:pivot.stationPrice) ) ) {
                    left[left.length] = list[i]
                }
                else {
                    right[right.length] = list[i]
                }
            }
            left = qmSort( by, left )
            right = qmSort( by, right )
            list = ( left.concat( [pivot] ) ).concat( right )
        }
        return list
    }
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contCol.height

        VerticalScrollDecorator {}

        Column {
            id: contCol
            width: page.width

            DialogHeader {
                acceptText: qsTr("Search")
                cancelText: ""
            }
            Loader {
                id: contentWrapper
                sourceComponent: content
                width: page.width-2*x
                x: Theme.horizontalPageMargin
            }
            Item {
                width: 1
                height: Theme.horizontalPageMargin*5
            }

            ComboBox {
                width: page.width-2*x
                x: Theme.horizontalPageMargin
                label: qsTr("Plugin")
                description: selectedPlugin.description
                value: selectedPlugin.name
                id:mfcb
                menu: ContextMenu {
                    MenuItem {
                        text: tk.name
                        onClicked: { changePlugin( tk ); mfcb.currentIndex = 0 }
                    }
                    MenuItem {
                        text: sv.name
                        onClicked: { changePlugin( sv ); mfcb.currentIndex = 1 }
                    }
                    MenuItem {
                        text: gg.name
                        onClicked: { changePlugin( gg ); mfcb.currentIndex = 2 }
                    }
                }
            }
        }
    }
}

