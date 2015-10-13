import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: afafa
    property int tmpSelFuel: selectedFuelType
    property string tmpName: selectedFuelTypeName
    onAccepted: {
        selectedFuelType = tmpSelFuel
        selectedFuelTypeName = tmpName
    }

    SilicaFlickable {
        contentHeight: col.height
        anchors.fill: parent
        VerticalScrollDecorator {}

       Column {
           id: col
           width: afafa.width
           DialogHeader { }
           Repeater {
                model: fuelBrands.length
                BackgroundItem {
                           width: afafa.width
                           highlighted: down || tmpSelFuel == fuelTypes[index].id
                           Text {
                                anchors.fill: parent
                                anchors.margins: Theme.paddingLarge
                                text: fuelTypes[index].name
                                color: Theme.primaryColor
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                           }
                           onClicked: {
                               tmpSelFuel = fuelTypes[index].id
                               tmpName = fuelTypes[index].name
                           }
                       }
           }
       }
    }
}
