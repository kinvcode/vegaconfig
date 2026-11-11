#ifndef CONFIGSTORE_H
#define CONFIGSTORE_H

#include <QJsonObject>
#include <QObject>
#include <QVariant>
#include <QtQml/qqmlregistration.h>

class ConfigStore : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(bool dirty READ dirty NOTIFY dirtyChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool statusError READ statusError NOTIFY statusChanged)
    Q_PROPERTY(int maxLevel READ maxLevel CONSTANT)

public:
    explicit ConfigStore(QObject *parent = nullptr);

    QString filePath() const;
    bool dirty() const;
    QString status() const;
    bool statusError() const;
    int maxLevel() const;

    Q_INVOKABLE void loadStartup();
    Q_INVOKABLE bool load(const QString &path);
    Q_INVOKABLE bool save();
    Q_INVOKABLE bool saveAs(const QString &path);
    Q_INVOKABLE void resetDefaults();
    Q_INVOKABLE void markDirty();
    Q_INVOKABLE void markClean();

    Q_INVOKABLE QVariant value(const QString &keyPath) const;
    Q_INVOKABLE void setValue(const QString &keyPath, const QVariant &value);
    Q_INVOKABLE void setStatus(const QString &text, bool error);

    Q_INVOKABLE QString pickConfigOpen() const;
    Q_INVOKABLE QString pickConfigSave() const;
    Q_INVOKABLE QString pickLauncher() const;
    Q_INVOKABLE QString launcherFromRegistry() const;

signals:
    void filePathChanged();
    void dirtyChanged();
    void statusChanged();
    void loaded();

private:
    static QJsonObject defaultData();
    static void mergeDefaults(QJsonObject &object);
    QString validate() const;
    QJsonValue valueAt(const QString &keyPath) const;
    void setFilePath(const QString &path);
    bool writeFile();

    QJsonObject m_data;
    QString m_filePath;
    QString m_status;
    bool m_dirty = false;
    bool m_statusError = false;
    bool m_loading = false;
    bool m_blockSave = false;
};

#endif
