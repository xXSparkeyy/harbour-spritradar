import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    clip: true
    id: page
    allowedOrientations: Orientation.All
    property alias searchRadius: sradius.value
    property alias useGps: gpsSwitch.checked
    property alias zipCode: postalCode.text
    property bool doSearch: false
    onStatusChanged: if( status === PageStatus.Deactivating) { if( doSearch) {doSearch = false; search(); settings.save()} }
    onAccepted: doSearch = true
    acceptDestination: list
    acceptDestinationAction: PageStackAction.Pop

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contCol.height

        VerticalScrollDecorator {}

        Column {
            id: contCol
            width: parent.width

            DialogHeader {
                acceptText: qsTr("Search")
                cancelText: ""
            }
            SectionHeader {
                text: qsTr("Fuel Type")
            }
            Row {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.horizontalPageMargin
                Button {
                    text: "Super (E5)"
                    width: parent.width/3 - 2*Theme.horizontalPageMargin/3
                    down: type == "e5"
                    onClicked: type = "e5"
                }
                Button {
                    text: "Super (E10)"
                    width: parent.width/3 - 2*Theme.horizontalPageMargin/3
                    down: type == "e10"
                    onClicked: type = "e10"
                }
                Button {
                    text: "Diesel"
                    width: parent.width/3 - 2*Theme.horizontalPageMargin/3
                    down: type == "diesel"
                    onClicked: type = "diesel"
                }
            }

            SectionHeader {
                text: qsTr("Search Radius")
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
                validator: RegExpValidator { regExp: /\d{5}/ }//IntValidator { bottom: 10000; top: 99999 }
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: focus = false
            }

            Rectangle {
                width: parent.width
                height: Theme.paddingLarge * 2
                color: "transparent"
            }

            Text {
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                height: paintedHeight
                horizontalAlignment: Text.AlignHCenter
                text: "Powered by www.tankerkoenig.de"
            }

            Rectangle {
                width: parent.width
                height: Theme.paddingLarge * 2
                color: "transparent"
            }
        }
    }
}
