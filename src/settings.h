#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);
    Q_INVOKABLE void setValue( QString path, QVariant value );
    Q_INVOKABLE QVariant getValue( QString path );
    Q_PROPERTY(QString name READ getname WRITE setname)
    QString getname() { return p_name; }
    void setname( QString n ) { p_name = n; }
signals:

public slots:
private:
    QString p_name;
};

#endif // SETTINGS_H
