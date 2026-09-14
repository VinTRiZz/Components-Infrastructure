#pragma once

#include <QObject>

#include <Components/Filework/ConfigParsing/IniParser.h>

/**
 * @brief The MasterManifest class Class to work with component manifest
 */
class MasterManifest : public QObject
{
    Q_OBJECT
public:
    explicit MasterManifest(QObject *parent = nullptr);

    bool setTargetFile(const QString& filePath);
    QString getTargetFile() const;

    bool init();
    bool save();

    QString     getVersion() const;

    void addSwitch(const QString& cmakeSwitch);
    void removeSwitch(const QString& cmakeSwitch);
    QStringList getCMakeSwitches() const;

    void addDepend(const QString& dep);
    void removeDepend(const QString& dep);
    QStringList getDepends() const;

private:
    QString m_targetFilePath;
    Filework::IniFileParser m_targetFile;

    QString     m_version;
    QStringList m_cmakeSwitches;
    QStringList m_depends;

    void initDefaultSwitches();
    void initDefaultDepends();
};
