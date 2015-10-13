import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    clip: true
    id: page
    property alias searchRadius: sradius.value
    property alias useGps: gpsSwitch.checked
    property alias zipCode: postalCode.text
    property bool doSearch: false
    onStatusChanged: if( status == PageStatus.Deactivating) { if( doSearch) {doSearch = false; search(); settings.save()} }
    onAccepted: doSearch = true
    acceptDestination: list
    acceptDestinationAction: PageStackAction.Pop
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contCol.height
        Column {
            id: contCol
            width: parent.width
            DialogHeader {
                acceptText: qsTr("Search")
                cancelText: ""
            }
            PageHeader {
                title: qsTr("Fuel Type")
            }
            Row {
                width: parent.width
                Button {
                    text: "Super (E5)"
                    width: parent.width/3
                    down: type == "e5"
                    onClicked: type = "e5"
                }
                Button {
                    text: "Super (E10)"
                    width: parent.width/3
                    down: type == "e10"
                    onClicked: type = "e10"
                }
                Button {
                    text: "Diesel"
                    width: parent.width/3
                    down: type == "diesel"
                    onClicked: type = "diesel"
                }
            }

            PageHeader {
                title: qsTr("Search Radius")
            }
            Slider {
                id: sradius
                width: page.width
                minimumValue: 1
                maximumValue: 25
                stepSize: 1
                value: 1
                //onValueChanged: searchRadius = value
                valueText: value+" km"
            }
            PageHeader {
                title: qsTr("Location")
            }
            TextSwitch {
                id: gpsSwitch
                text: qsTr("Use GPS")
            }
            TextField {
                id: postalCode
                placeholderText: qsTr("Zip Code")
                label: placeholderText
                labelVisible: true
                width: parent.width
                readOnly: useGps
                onTextChanged: zipCode = text
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: RegExpValidator { regExp: /\d{5}/ }//IntValidator { bottom: 10000; top: 99999 }
            }
            Text {
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                height: paintedHeight
                horizontalAlignment: Text.AlignHCenter
                text: "Powered by www.tankerkoenig.de"
            }
        }
    }
}
