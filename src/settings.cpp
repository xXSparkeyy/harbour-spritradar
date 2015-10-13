#include "settings.h"

Settings::Settings(QObject *parent) :
    QObject(parent)
{
    //settingsPath = "/home/nemo/.config/Sparkeyy/SpritScope/settings.ini";
}
void Settings::setValue(QString path, QVariant value) { QSettings sttngs; sttngs.setValue( path, value ); }
QVariant Settings::getValue(QString path) { QSettings sttngs; return sttngs.value( path ); }
