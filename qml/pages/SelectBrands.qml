import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: afafa
    property int tmpSelFuel: selectedFuelBrand
    property string tmpName: selectedFuelType
    onAccepted: {
        selectedFuelBrand = tmpSelFuel
        selectedFuelBrandName = tmpName
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
                           highlighted: down || tmpSelFuel == fuelBrands[index].id
                           Text {
                                anchors.fill: parent
                                anchors.margins: Theme.paddingLarge
                                text: fuelBrands[index].name
                                color: Theme.primaryColor
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                           }
                           onClicked: {
                               tmpSelFuel = fuelBrands[index].id
                               tmpName = fuelBrands[index].name
                           }
                       }
           }
       }
    }
}
