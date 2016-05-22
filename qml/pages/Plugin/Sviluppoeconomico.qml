import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.SpritRadar.Util 1.0

Plugin {
    id: page

    name: "IT - Osservaprezzi Carburanti"
    description: "Fonte: Ministero dello Sviluppo Economico"
    Connections {
        target: contentItem
        onUseGpsChanged: gpsActive = contentItem.useGps
    }
    settings: Settings {
        name: "sviluppoeconomico"

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
            setValue( "type", "Benzina" )
            setValue( "sort", main.sort )
            setValue( "gps", false )
            setValue( "zipCode", "" )
        }
    }

    SVManager {
        id: manager
        radius: contentItem.searchRadius*1000;
        lat: position.position.coordinate.latitude
        lng: position.position.coordinate.longitude


    }
    function prepare() {
        manager.prepare()
        settings.load()
        pluginReady = true
    }



    function requestItems() {
        if( contentItem.useGps ) getItems( latitude, longitude )
        var req = new XMLHttpRequest()
        req.open( "GET", "http://maps.google.com/maps/api/geocode/json?components=country:IT|postal_code:"+contentItem.zipCode )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var x = eval( req.responseText ).results[0].geometry.location
                    getItems( x.lat, x.lng )
                }
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
        manager.lat = lat
        manager.lng = lng
        errorCode = 0
        itemsBusy = true
        items.clear()
        coverItems.clear()
        manager.getStations();
    }
    Connections {
        target: manager
        onGotStations: {
            //try {
                var x = eval( stations )
                for( var i = 0; i < x.length; i++ ) {
                    var o = x[i]
                    var price = { price:0 }
                    for( var j = 0; j < o.prices.length; j++ ) {
                        if( o.prices[j].type.toLowerCase() == contentItem.type.toLowerCase() && ( price > o.prices[j].price || price == 0 ) ) price = o.prices[j]
                        else if( o.prices[j].type.toLowerCase().indexOf( contentItem.type.toLowerCase().substring(2, contentItem.type.length) ) > -1 && o.prices[j].type.toLowerCase() != contentItem.type.substring(2, contentItem.type.length).toLowerCase() && ( price.price > o.prices[j].price || price.price == 0 ) ) price = o.prices[j]
                    }
                    if( price.price == 0 ) continue
                    var itm = {
                        "stationID": o.id,
                        "stationName": (o.brand=="Pompe Bianche"?"":o.brand+" - ")+o.name,
                        "stationPrice": price.price,
                        "stationAdress": o.adress.replace("?", ", "),//capitalizeString(o.street) + (typeof(o.houseNumber) == "object" ? "" : " " + o.houseNumber) + ", " + o.postCode + " " + capitalizeString(o.place),
                        "stationDistance": o.distance,
                        "customMessage": price.self?"":qsTr("Serviced")
                    }
                    items.append( itm )
                }
                sort()
                itemsBusy = false
                errorCode = items.count < 1 ? 1 : 0
            try{}
            catch ( e ) {
                items.clear()
                itemsBusy = false
                errorCode = 3
            }
        }
    }

    function requestStation( id ) {
        stationBusy = true
        station = {}
        stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
        manager.getStation( id )
    }
    Connections {
        target: manager
        onGotStation: {
            //try {
                console.log( station )
                var st = eval( station )
                var price = []
                for( var j = 0; j < st.prices.length; j++ ) {
                    price[price.length] = { "title":st.prices[j].type+(st.prices[j].self?"":" ("+qsTr("Serviced")+")"), "price":st.prices[j].price, "sz":Theme.fontSizeLarge, "tf":true }
                }
                console.log( st.adress )
                var adress = st.adress.split("?")
                var street = adress[0].split( " " )
                var zipcode = street[street.length-1]
                street = street.splice(0, street.length-1).join(" ")
                adress = adress[1].split(" ")
                var provincia = adress[adress.length-1]
                adress = adress.splice(0, adress.length-1).join(" ")
                var county = zipcode+" "+adress
                page.station = {
                    "stationID":st.id,
                    "stationName":(st.brand=="Pompe Bianche"?"":st.brand+" - ")+st.name,
                    "stationAdress": {
                        "street":capitalizeString(street),
                        "county":capitalizeString(county)+" "+provincia,
                        "country":"Italy",
                        "latitude":st.lat,
                        "longitude":st.lng
                    },
                    "content": [
                        { "title":qsTr("Info"), items:[ {title:qsTr("Brand"), text:st.brand=="Pompe Bianche"?qsTr("Off-Brand"):st.brand},{title:qsTr("Updated"), text:st.prices[0].date} ] },
                        { "title":qsTr("Prices"), "items": price }

                    ]
                }
                stationBusy = false
            try{}
            catch ( e ) {
                page.station = {}
                stationBusy = false
            }
            stationPage.station = page.station
        }

    }

    content: Component {
        Column {
            property alias searchRadius: sradius.value
            property alias useGps: gpsSwitch.checked
            property alias zipCode: postalCode.text
            property string type: "Benzina"

            SectionHeader {
                text: qsTr("Fuel Type")
            }
            Row {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall
                Button {
                    text: qsTr("Benzin")
                    width: parent.width/4 - parent.spacing
                    down: type == "Benzina"
                    onClicked: type = "Benzina"
                }
                Button {
                    text: qsTr("Diesel")
                    width: parent.width/4 - parent.spacing
                    down: type == "Gasolio"
                    onClicked: type = "Gasolio"
                }
                Button {
                    text: qsTr("Methan")
                    width: parent.width/4 - parent.spacing
                    down: type == "Metano"
                    onClicked: type = "Metano"
                }
                Button {
                    text: qsTr("Methan")
                    width: parent.width/4
                    down: type == "Metano"
                    onClicked: type = "Metano"
                }
            }
            Item {
                width: 1
                height: Theme.paddingSmall
            }

            Row {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall
                Button {
                    text: qsTr("Benzin")+" "+qsTr( "Special" )
                    width: parent.width/2 - parent.spacing
                    down: type == "spbenzina"
                    onClicked: type = "spbenzina"
                }
                Button {
                    text: qsTr("Diesel")+" "+qsTr( "Special" )
                    width: parent.width/2
                    down: type == "spgasolio"
                    onClicked: type = "spgasolio"
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

