import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: stationPage
    clip: true
    allowedOrientations: Orientation.All
    property string stationId: ""
    property variant station: ({ })

    SilicaFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.verticalPageMargin
        anchors.bottomMargin: Theme.verticalPageMargin
        contentHeight: stationDetails.height
        id: page
        PullDownMenu {
            busy: selectedPlugin.stationBusy
            enabled: selectedPlugin.supportsFavs
            MenuItem {
                text: ( isFav( stationId ) ? qsTr( "Unset as Favourite" ) : qsTr( "Set as Favourite" ) )
                onClicked: ( isFav( stationId ) ? unsetFav : setFav )(stationId, station.stationName)
            }
        }

        VerticalScrollDecorator {}

        Image {
            id: maptile
            width: parent.width
            height: Math.round(selectedPlugin.stationBusy?0:stationPage.height/2.5)
            onHeightChanged: if(!selectedPlugin.stationBusy && station.stationAdress && source != "https://api.mapbox.com/v4/mapbox.dark/pin-l-fuel+"+(Theme.highlightColor+"").replace("#","")+"("+station.stationAdress.longitude+","+station.stationAdress.latitude+")/"+station.stationAdress.longitude+","+station.stationAdress.latitude+",17/"+Math.min(1200,width)+"x"+Math.min(1200,height)+".png?access_token=pk.eyJ1Ijoic3BhcmtleXkiLCJhIjoiY2l0MzhxODdjMDBkNDJ0bzNoMWsyd2c1YyJ9.m-yBA1wgLm3Ps_PxQ1Oasg" ) source = "https://api.mapbox.com/v4/mapbox.dark/pin-l-fuel+"+(Theme.highlightColor+"").replace("#","")+"("+station.stationAdress.longitude+","+station.stationAdress.latitude+")/"+station.stationAdress.longitude+","+station.stationAdress.latitude+",17/"+Math.min(1200,width)+"x"+Math.min(1200,height)+".png?access_token=pk.eyJ1Ijoic3BhcmtleXkiLCJhIjoiY2l0MzhxODdjMDBkNDJ0bzNoMWsyd2c1YyJ9.m-yBA1wgLm3Ps_PxQ1Oasg"
            Rectangle {
                color: Theme.highlightColor
                anchors.fill: parent
                opacity: Theme.highlightBackgroundOpacity
                visible: addressContainer.pressed
            }
            opacity: addressContainer.pressed?Theme.highlightBackgroundOpacity:0
        }
        OpacityRampEffect {
                sourceItem: maptile
                direction: OpacityRamp.TopToBottom
                offset: 0.75
                slope: 1/(1-offset)
        }

        Column {
            id: stationDetails
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-2*Theme.horizontalPageMargin

            PageHeader {
                title: station.stationName?station.stationName:""
            }

            MouseArea {
                height: address.paintedHeight + 2*Theme.paddingLarge
                width: parent.width
                onClicked: Qt.openUrlExternally( "geo:"+station.stationAdress.latitude+","+station.stationAdress.longitude )
                id: addressContainer
                visible: !selectedPlugin.stationBusy
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
                    text: typeof(station.stationAdress) == "object"? ( station.stationAdress.street+"\n"+station.stationAdress.county +(station.stationAdress.country?"\n"+station.stationAdress.country:"" ) ):""
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
                        width: stationDetails.width
                        property variant items: station.content[index]?station.content[index].items:[]
                        SectionHeader {
                            visible: station.content[index]?station.content[index].title!="":false
                            text: station.content[index]?qsTr(station.content[index].title):""
                        }
                        Repeater {
                            model: items.length
                            delegate: ListText {
                                Component.onCompleted: {
                                    if( items[index].tf ) titlefade = items[index].tf
                                    if( items[index].sz ) size = items[index].sz
                                }
                                width: stationDetails.width
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
