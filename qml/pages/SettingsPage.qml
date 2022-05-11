/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Page {
    id: settingsPage
    property var tankerkoenig_apikey
    property var apiKey

    allowedOrientations: Orientation.All
    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            settings.save()
        }
    }
    Settings {
        id: settings
        name: "tankerkoenig"

        function save() {
            setValue( "apiKey", apiKey )
        }
        function load() {
            apiKey = getValue( "apiKey" )
            tKapiKeyText.text = apiKey
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
         Component.onCompleted: {
             settings.load()
         }

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            TextField {
                id: tKapiKeyText
                label: qsTr("TankerKoenig API key")
                width: parent.width
                onTextChanged: {
                    apiKey = text
                    settings.save()
                }


            }
        }
    }

}

