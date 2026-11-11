#include "configstore.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileDialog>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonValue>
#include <QSettings>
#include <QUrl>

namespace {
constexpr int kMaxLevel = 115;
constexpr int kMaxFame = 999999;

QString localPath(QString path)
{
    if (path.startsWith(QStringLiteral("file:")))
        path = QUrl(path).toLocalFile();
    return QDir::cleanPath(path);
}

int jsonInt(const QJsonObject &object, const QString &group, const QString &key)
{
    return object.value(group).toObject().value(key).toVariant().toInt();
}
}

ConfigStore::ConfigStore(QObject *parent)
    : QObject(parent)
    , m_data(defaultData())
{
}

QString ConfigStore::filePath() const
{
    return m_filePath;
}

bool ConfigStore::dirty() const
{
    return m_dirty;
}

QString ConfigStore::status() const
{
    return m_status;
}

bool ConfigStore::statusError() const
{
    return m_statusError;
}

int ConfigStore::maxLevel() const
{
    return kMaxLevel;
}

QJsonObject ConfigStore::defaultData()
{
    return QJsonObject{
        {"BindMachine", QJsonObject{
            {"Identifier", QString()}
        }},
        {"BaseSet", QJsonObject{
            {"stop_users", 0},
            {"dungeon_timeout", 480},
            {"shutdown_after_finishing", false},
            {"clean_backpack", false},
            {"play_role_index", 0},
            {"neo_wear_equipment", false}
        }},
        {"Timestamp", QJsonObject{
            {"switch_role_time", 0}
        }},
        {"GameLogin", QJsonObject{
            {"login_type", 0},
            {"game_account", QString()},
            {"game_password", QString()},
            {"OTP_SECRET", QString()},
            {"neoplelauncher_path", QString()},
            {"email_account", QString()},
            {"email_password", QString()},
            {"help_email_account", QString()},
            {"help_email_password", QString()}
        }},
        {"VIPLogin", QJsonObject{
            {"ms_name", QString()},
            {"ms_password", QString()},
            {"qq", QString()}
        }},
        {"CAPTCHA", QJsonObject{
            {"verify_platform", 0},
            {"verify_action", 0},
            {"cjy_account", QString()},
            {"cjy_password", QString()}
        }},
        {"ProcessingEquip", QJsonObject{
            {"rare", 0},
            {"unique", 0},
            {"epic", 0}
        }},
        {"CustomBUFF", QJsonObject{
            {"overall_damage", 1000},
            {"max_hp", 99999999},
            {"max_mp", 999999},
            {"attack_speed", 100},
            {"casting_speed", 100},
            {"movement_speed", 100}
        }},
        {"AutoModeSwitch", QJsonObject{
            {"doom", true},
            {"doom_pro", true},
            {"uplevel", true},
            {"cleandungeon", true},
            {"cleandungeon2", true}
        }},
        {"AutoModeDoom", QJsonObject{
            {"oracle_num", 2000}
        }},
        {"AutoModeDoomPro", QJsonObject{
            {"oracle_num", 2000},
            {"weight_num", 3}
        }},
        {"AutoModeUpLevel", QJsonObject{
            {"min_level", 1},
            {"max_level", kMaxLevel}
        }},
        {"AutoModeCleanDungeon", QJsonObject{
            {"min_level", 1},
            {"max_level", kMaxLevel},
            {"min_fame", 1},
            {"max_fame", kMaxFame},
            {"dungeon_map", 0},
            {"dungeon_difficulty", 0}
        }},
        {"AutoModeCleanDungeon2", QJsonObject{
            {"min_level", 1},
            {"max_level", kMaxLevel},
            {"min_fame", 1},
            {"max_fame", kMaxFame},
            {"dungeon_map", 0},
            {"dungeon_difficulty", 0}
        }},
        {"signed", QStringLiteral("c7643d2002e36e4aacd822d7ad11803a")}
    };
}

void ConfigStore::mergeDefaults(QJsonObject &object)
{
    const QJsonObject defaults = defaultData();
    for (auto it = defaults.constBegin(); it != defaults.constEnd(); ++it) {
        if (it.value().isObject()) {
            QJsonObject sub = object.value(it.key()).toObject();
            const QJsonObject defSub = it.value().toObject();
            for (auto jt = defSub.constBegin(); jt != defSub.constEnd(); ++jt) {
                if (!sub.contains(jt.key()))
                    sub.insert(jt.key(), jt.value());
            }
            object.insert(it.key(), sub);
        } else if (!object.contains(it.key())) {
            object.insert(it.key(), it.value());
        }
    }
}

void ConfigStore::loadStartup()
{
    QSettings settings;
    QString last = settings.value(QStringLiteral("lastConfig")).toString();
    if (last.isEmpty())
        last = QCoreApplication::applicationDirPath() + QStringLiteral("/config.json");
    load(last);
}

bool ConfigStore::load(const QString &path)
{
    setFilePath(localPath(path));
    m_loading = true;
    m_blockSave = false;
    m_data = defaultData();

    QFile file(m_filePath);
    if (!file.exists()) {
        m_loading = false;
        m_dirty = true;
        emit dirtyChanged();
        emit loaded();
        setStatus(QStringLiteral("配置文件不存在，已载入默认配置"), false);
        return true;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_loading = false;
        m_blockSave = true;
        m_dirty = false;
        emit dirtyChanged();
        emit loaded();
        setStatus(QStringLiteral("无法读取配置文件"), true);
        return false;
    }

    QJsonParseError parseError;
    const QByteArray raw = file.readAll();
    file.close();
    const QJsonDocument doc = QJsonDocument::fromJson(raw, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        m_loading = false;
        m_blockSave = true;
        m_dirty = false;
        emit dirtyChanged();
        emit loaded();
        const QString reason = parseError.error == QJsonParseError::NoError
            ? QStringLiteral("配置文件不是 JSON 对象")
            : QStringLiteral("JSON 解析失败: ") + parseError.errorString();
        setStatus(reason + QStringLiteral("，已停止覆盖原文件"), true);
        return false;
    }

    const QJsonObject original = doc.object();
    m_data = original;
    mergeDefaults(m_data);
    m_loading = false;
    m_dirty = (m_data != original);
    emit dirtyChanged();
    emit loaded();
    QSettings().setValue(QStringLiteral("lastConfig"), m_filePath);
    if (m_dirty)
        setStatus(QStringLiteral("已加载，并补全了缺失配置项"), false);
    else
        setStatus(QStringLiteral("已加载"), false);
    return true;
}

bool ConfigStore::save()
{
    if (m_filePath.isEmpty()) {
        setStatus(QStringLiteral("请先选择保存路径"), true);
        return false;
    }
    if (m_blockSave) {
        setStatus(QStringLiteral("原文件无法解析，请使用另存为"), true);
        return false;
    }
    const QString error = validate();
    if (!error.isEmpty()) {
        setStatus(error, true);
        return false;
    }
    if (!writeFile())
        return false;
    m_dirty = false;
    emit dirtyChanged();
    QSettings().setValue(QStringLiteral("lastConfig"), m_filePath);
    setStatus(QStringLiteral("已保存 ") + m_filePath, false);
    return true;
}

bool ConfigStore::saveAs(const QString &path)
{
    if (path.isEmpty())
        return false;
    m_blockSave = false;
    setFilePath(localPath(path));
    return save();
}

void ConfigStore::resetDefaults()
{
    const QString signedValue = m_data.value(QStringLiteral("signed")).toString();
    m_loading = true;
    m_data = defaultData();
    if (!signedValue.isEmpty())
        m_data.insert(QStringLiteral("signed"), signedValue);
    m_loading = false;
    m_blockSave = false;
    m_dirty = true;
    emit dirtyChanged();
    emit loaded();
    setStatus(QStringLiteral("已恢复默认值，尚未写入文件"), false);
}

void ConfigStore::markDirty()
{
    if (m_loading || m_dirty)
        return;
    m_dirty = true;
    emit dirtyChanged();
}

void ConfigStore::markClean()
{
    if (!m_dirty)
        return;
    m_dirty = false;
    emit dirtyChanged();
}

QVariant ConfigStore::value(const QString &keyPath) const
{
    return valueAt(keyPath).toVariant();
}

QJsonValue ConfigStore::valueAt(const QString &keyPath) const
{
    const QStringList keys = keyPath.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    if (keys.isEmpty())
        return QJsonValue();
    if (keys.size() == 1)
        return m_data.value(keys.at(0));

    QJsonValue current = m_data.value(keys.at(0));
    for (int i = 1; i < keys.size(); ++i) {
        if (!current.isObject())
            return QJsonValue();
        current = current.toObject().value(keys.at(i));
    }
    return current;
}

void ConfigStore::setValue(const QString &keyPath, const QVariant &newValue)
{
    const QStringList keys = keyPath.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    if (keys.isEmpty() || keys.size() > 2)
        return;

    const QJsonValue stored = QJsonValue::fromVariant(newValue);
    if (keys.size() == 1) {
        if (m_data.value(keys.at(0)) == stored)
            return;
        m_data.insert(keys.at(0), stored);
    } else {
        QJsonObject group = m_data.value(keys.at(0)).toObject();
        if (group.value(keys.at(1)) == stored)
            return;
        group.insert(keys.at(1), stored);
        m_data.insert(keys.at(0), group);
    }

    if (!m_loading && !m_dirty) {
        m_dirty = true;
        emit dirtyChanged();
    }
}

void ConfigStore::setStatus(const QString &text, bool error)
{
    if (m_status == text && m_statusError == error)
        return;
    m_status = text;
    m_statusError = error;
    emit statusChanged();
}

QString ConfigStore::validate() const
{
    const int timeout = jsonInt(m_data, QStringLiteral("BaseSet"), QStringLiteral("dungeon_timeout"));
    if (timeout <= 0)
        return QStringLiteral("副本超时必须大于 0");
    if (jsonInt(m_data, QStringLiteral("BaseSet"), QStringLiteral("stop_users")) < 0)
        return QStringLiteral("停止角色数不能小于 0");

    const int playIndex = jsonInt(m_data, QStringLiteral("BaseSet"), QStringLiteral("play_role_index"));
    if (playIndex < 0)
        return QStringLiteral("当前角色序号不能小于 0");

    auto levelOk = [](int level) { return level >= 1 && level <= kMaxLevel; };
    auto fameOk = [](int fame) { return fame >= 1 && fame <= kMaxFame; };
    auto checkRange = [&](const QString &group, const QString &title) -> QString {
        const int minLevel = jsonInt(m_data, group, QStringLiteral("min_level"));
        const int maxLevel = jsonInt(m_data, group, QStringLiteral("max_level"));
        if (!levelOk(minLevel) || !levelOk(maxLevel))
            return title + QStringLiteral("：等级必须在 1 到 115 之间");
        if (group != QStringLiteral("AutoModeUpLevel")) {
            const int minFame = jsonInt(m_data, group, QStringLiteral("min_fame"));
            const int maxFame = jsonInt(m_data, group, QStringLiteral("max_fame"));
            if (!fameOk(minFame) || !fameOk(maxFame))
                return title + QStringLiteral("：名望必须在 1 到 999999 之间");
            const int difficulty = jsonInt(m_data, group, QStringLiteral("dungeon_difficulty"));
            if (difficulty < 0 || difficulty > 4)
                return title + QStringLiteral("：难度无效");
        }
        return {};
    };

    if (jsonInt(m_data, QStringLiteral("AutoModeDoom"), QStringLiteral("oracle_num")) < 49)
        return QStringLiteral("最终调律：深渊票数量必须大于等于 49");
    if (jsonInt(m_data, QStringLiteral("AutoModeDoomPro"), QStringLiteral("oracle_num")) < 750)
        return QStringLiteral("调律边界：深渊票数量必须大于等于 750");
    if (jsonInt(m_data, QStringLiteral("AutoModeDoomPro"), QStringLiteral("weight_num")) < 3)
        return QStringLiteral("调律边界：砝码数量必须大于等于 3");

    const QString upLevelError = checkRange(QStringLiteral("AutoModeUpLevel"), QStringLiteral("自动升级"));
    if (!upLevelError.isEmpty())
        return upLevelError;
    const QString map1Error = checkRange(QStringLiteral("AutoModeCleanDungeon"), QStringLiteral("搬砖地图1"));
    if (!map1Error.isEmpty())
        return map1Error;
    const QString map2Error = checkRange(QStringLiteral("AutoModeCleanDungeon2"), QStringLiteral("搬砖地图2"));
    if (!map2Error.isEmpty())
        return map2Error;

    auto equipOk = [&](const QString &key) {
        const int index = jsonInt(m_data, QStringLiteral("ProcessingEquip"), key);
        return index == 0 || index == 1;
    };
    if (!equipOk(QStringLiteral("rare")) || !equipOk(QStringLiteral("unique")) || !equipOk(QStringLiteral("epic")))
        return QStringLiteral("装备处理选项无效");

    const int loginType = jsonInt(m_data, QStringLiteral("GameLogin"), QStringLiteral("login_type"));
    if (loginType != 0 && loginType != 1)
        return QStringLiteral("登录方式无效");

    const int platform = jsonInt(m_data, QStringLiteral("CAPTCHA"), QStringLiteral("verify_platform"));
    const int action = jsonInt(m_data, QStringLiteral("CAPTCHA"), QStringLiteral("verify_action"));
    if (platform != 0 && platform != 1)
        return QStringLiteral("识别平台无效");
    if (action < 0 || action > 4)
        return QStringLiteral("验证操作无效");

    return {};
}

QString ConfigStore::pickConfigOpen() const
{
    const QString dir = QFileInfo(m_filePath).absolutePath();
    return QFileDialog::getOpenFileName(nullptr,
                                        QStringLiteral("打开配置"),
                                        dir,
                                        QStringLiteral("JSON (*.json);;所有文件 (*.*)"));
}

QString ConfigStore::pickConfigSave() const
{
    const QString dir = m_filePath.isEmpty()
        ? QCoreApplication::applicationDirPath() + QStringLiteral("/config.json")
        : m_filePath;
    return QFileDialog::getSaveFileName(nullptr,
                                        QStringLiteral("配置另存为"),
                                        dir,
                                        QStringLiteral("JSON (*.json)"));
}

QString ConfigStore::pickLauncher() const
{
    const QString current = value(QStringLiteral("GameLogin/neoplelauncher_path")).toString();
    const QString dir = current.isEmpty() ? QFileInfo(m_filePath).absolutePath() : QFileInfo(current).absolutePath();
    return QFileDialog::getOpenFileName(nullptr,
                                        QStringLiteral("选择 NeopleLauncher.exe"),
                                        dir,
                                        QStringLiteral("可执行文件 (*.exe);;所有文件 (*.*)"));
}

QString ConfigStore::launcherFromRegistry() const
{
    QSettings dfoReg(QStringLiteral("HKEY_CURRENT_USER\\SOFTWARE\\Neople_DFO"), QSettings::NativeFormat);
    QString gameDir = dfoReg.value(QStringLiteral("Path")).toString().trimmed();
    if (gameDir.isEmpty())
        gameDir = dfoReg.value(QStringLiteral(".")).toString().trimmed();
    if (gameDir.isEmpty())
        return {};

    const QFileInfo info(gameDir);
    if (info.isDir()) {
        const QString launcher = QDir(info.absoluteFilePath()).filePath(QStringLiteral("NeopleLauncher.exe"));
        if (QFile::exists(launcher))
            return QDir::toNativeSeparators(launcher);
    }
    return QDir::toNativeSeparators(gameDir);
}

void ConfigStore::setFilePath(const QString &path)
{
    if (m_filePath == path)
        return;
    m_filePath = path;
    emit filePathChanged();
}

bool ConfigStore::writeFile()
{
    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        setStatus(QStringLiteral("无法写入: ") + m_filePath, true);
        return false;
    }
    file.write(QJsonDocument(m_data).toJson(QJsonDocument::Indented));
    file.close();
    return true;
}
