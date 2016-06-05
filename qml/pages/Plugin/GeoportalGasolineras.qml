import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "ES - GeoportalGasolineras.es"
    description: "Ministerio de Industria, Energía y Turismo"
    units: { "currency":"€", "distance": "km" }
    property string url: "http://spritradar.w4f.eu/es/"
    Connections {
        target: contentItem
        onUseGpsChanged: gpsActive = contentItem.useGps
    }
    settings: Settings {
        name: "GeoportalGasolineras"

        function save() {
            setValue( "radius", contentItem.searchRadius )
            setValue( "type", contentItem.type )
            setValue( "sort", main.sort )
            setValue( "gps", contentItem.useGps )
            setValue( "zipCode", contentItem.zipCode )
        }
        function load() {
            try {
                contentItem.searchRadius = getValue( "radius" )
                contentItem.type = getValue( "type" )
                main.sort = getValue( "sort" )
                contentItem.useGps = eval( getValue( "gps" ) )
                contentItem.zipCode = getValue( "zipCode" )
                favs.load()
            }
            catch( e ) {
                assign()
                load()
            }
        }
        function assign() {
            setValue( "radius", 1 )
            setValue( "type", "GPR" )
            setValue( "sort", main.sort )
            setValue( "gps", false )
            setValue( "zipCode", "" )
        }
    }
    function prepare() {
        settings.load()
        pluginReady = true
    }



    function requestItems() {
        console.log("heyy")
        if( contentItem.useGps ) getItems( latitude, longitude )
        var req = new XMLHttpRequest()
        req.open( "GET", "http://maps.google.com/maps/api/geocode/json?components=country:ES|postal_code:"+contentItem.zipCode )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                    console.log("ho")
                    var x = eval( req.responseText ).results[0].geometry.location
                    getItems( x.lat, x.lng )
                try{}
                catch( e ) {
                    items.clear()
                    itemsBusy = false
                    errorCode = 2
                }
            }
        }
        req.send()
    }
    function getItems( lat, lng ) {
        errorCode = 0
        itemsBusy = true
        items.clear()
        coverItems.clear()
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?get=stations&lat="+lat+"&lng="+lng+"&radius="+contentItem.searchRadius )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                //try {
                console.log(req.responseText)
                    var x = eval( req.responseText )
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var price = { price:0 }
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].type.toLowerCase() == contentItem.type.toLowerCase() ) price = o.prices[j]
                        }
                        if( price.price == 0 ) continue
                        var itm = {
                            "stationID": o.id,
                            "stationName": o.name,
                            "stationPrice": price.price,
                            "stationAdress": o.open,
                            "stationDistance": o.distance,
                            "customMessage": ""
                        }
                        items.append( itm )
                    }
                    sort()
                    itemsBusy = false
                    errorCode = items.count < 1 ? 1 : 0
                try {}
                catch ( e ) {
                    items.clear()
                    itemsBusy = false
                    errorCode = 3
                }
            }
        }
        req.send()
    }
    function requestStation( id ) {
        stationBusy = true
        station = {}
        stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?get=station&id="+id )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                //try {
                    var st = eval( req.responseText )
                    var price = []
                    for( var j = 0; j < st.prices.length; j++ ) {
                        price[price.length] = { "title":st.prices[j].type, "price":st.prices[j].price, "sz":Theme.fontSizeLarge, "tf":true }
                    }
                    page.station = {
                        "stationID":st.id,
                        "stationName":st.name,
                        "stationAdress": {
                            "street":"No Street",
                            "county":"No Place",
                            "country":"Spain",
                            "latitude":st.lat,
                            "longitude":st.lng
                        },
                        "content": [
                            { "title":qsTr("Info"), items:[ {title:qsTr("Opening Times"), text:st.open } ] },
                            { "title":qsTr("Prices"), "items": price }

                        ]
                    }
                    stationBusy = false
                try {}
                catch ( e ) {
                    page.station = {}
                    stationBusy = false
                }
                stationPage.station = page.station
            }
        }
        req.send()
    }

    content: Component {
        Column {
            property alias searchRadius: sradius.value
            property alias useGps: gpsSwitch.checked
            property alias zipCode: postalCode.text
            property string type: "GPR"
            property variant types: ['GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC']

            SectionHeader {
                text: qsTr("Fuel Type")
            }

            ComboBox {
                width: parent.width
                    label: "Select Fuel"

                    menu: ContextMenu {
                        Repeater {
                            model: types.length
                            MenuItem {
                                text: types[index]
                                onClicked: type = types[index]
                            }
                        }
                    }
            }

            SectionHeader {
                text: qsTr("Search Radius")
            }
            Slider {
                id: sradius
                width: parent.width
                minimumValue: 1
                maximumValue: 25
                stepSize: 1
                value: 1
                valueText: value+" km"
            }

            SectionHeader {
                text: qsTr("Location")
            }

            TextSwitch {
                id: gpsSwitch
                text: qsTr("Use GPS")
            }

            TextField {
                id: postalCode
                placeholderText: qsTr("Zip Code")
                label: placeholderText
                width: parent.width
                readOnly: useGps
                onTextChanged: zipCode = text
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: RegExpValidator { regExp: /\d{5}/ }
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: focus = false
            }
        }
    }
}

