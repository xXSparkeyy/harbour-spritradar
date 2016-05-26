import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    clip: true
    allowedOrientations: Orientation.All
    property string stationId: ""
    property variant station: ({ })
    onStationChanged: log( station )

    SilicaFlickable {
        anchors.fill: parent
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.topMargin: Theme.verticalPageMargin
        anchors.bottomMargin: Theme.verticalPageMargin
        contentHeight: stationDetails.height
        id: page
        PullDownMenu {
            active: stationLoading
            MenuItem {
                text: ( isFav( stationId ) ? qsTr( "Unset as Favourite" ) : qsTr( "Set as Favourite" ) )
                onClicked: ( isFav( stationId ) ? unsetFav : setFav )(stationId, station.name)
            }
        }

        VerticalScrollDecorator {}

        Column {
            id: stationDetails
            anchors.right: parent.right
            anchors.left: parent.left

            PageHeader {
                title: station.stationName?station.stationName:""
            }

            BackgroundItem {
                height: address.paintedHeight + 2*Theme.paddingLarge
                width: parent.width
                onClicked: Qt.openUrlExternally( "geo:"+station.stationAdress.latitude+","+station.stationAdress.longitude )
                id: addressContainer
                Label {
                    id: address
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingLarge
                    anchors.right: ico.left
                    anchors.rightMargin: Theme.paddingLarge
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    //Adresse
                    text: typeof(station.stationAdress) == "object"? ( station.stationAdress.street+"\n"+station.stationAdress.county +(station.stationAdress.country?", "+station.stationAdress.country:"" ) ):""
                    color: addressContainer.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    verticalAlignment: Text.AlignVCenter
                }
                Image {
                    id: ico
                    source: "image://theme/icon-m-whereami?" + (addressContainer.down
                                 ? Theme.highlightColor
                                 : Theme.primaryColor)
                    width: height
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: Theme.paddingLarge
                }
            }
            Repeater {
                    model: station.content?station.content.length:0
                    delegate: Column {
                        width: page.width
                        property variant items: station.content[index].items
                        SectionHeader {
                            visible: station.content[index].title!=""
                            text: qsTr(station.content[index].title)
                        }
                        Repeater {
                            model: items.length
                            delegate: ListText {
                                Component.onCompleted: {
                                    if( items[index].tf ) titlefade = items[index].tf
                                    if( items[index].sz ) size = items[index].sz
                                }
                                width: page.width
                                anchors.horizontalCenter: parent.horizontalCenter
                                title: items[index].title
                                text: items[index].text?items[index].text:items[index].price+selectedPlugin.units.currency
                            }
                        }
                    }
            }
        }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: visible
        size: BusyIndicatorSize.Large
        visible: selectedPlugin.stationBusy
    }
}
