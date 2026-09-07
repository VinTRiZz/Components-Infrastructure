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

    QStringList getDepends() const;

private:
    QString m_targetFilePath;
    Filework::IniFileParser m_targetFile;

    QStringList m_depends;
};
