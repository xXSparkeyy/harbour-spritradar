# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-spritradar
QT+=positioning network concurrent
CONFIG += sailfishapp

HEADERS += \
    src/settings.h

SOURCES += src/harbour-spritradar.cpp \
    src/settings.cpp

OTHER_FILES += qml/harbour-spritradar.qml \
    qml/cover/*.qml \
    qml/pages/*.qml \
    qml/pages/Plugin/*.qml \
    rpm/harbour-spritradar.yaml \
    translations/*.ts \
    harbour-spritradar.desktop \
    rpm/harbour-spritradar.changes

!defined(TANKERKOENIG_APIKEY, var) {
    error("Please provide Tankerkoenig API key as argument of qmake, e.g. 'qmake TANKERKOENIG_APIKEY=<your API key here>'")
}

DEFINES += TANKERKOENIG_APIKEY=\\\"$$TANKERKOENIG_APIKEY\\\"

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-spritradar.ts \
                translations/harbour-spritradar-de.ts \
                translations/harbour-spritradar-es.ts \
                translations/harbour-spritradar-it.ts

DISTFILES += \
    qml/pages/Plugin/MyGasFeed.qml \
    qml/pages/Plugin/SpritpreisRechner.qml \
    php/es/db.php \
    php/es/index.php \
    php/it/db.php \
    php/it/index.php \
    php/db.php \
    php/index.php \
    rpm/harbour-spritradar.yaml \
    harbour-spritradar.png \
    qml/pages/Plugin/PrixCarburants.qml



