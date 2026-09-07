#pragma once

#include <QObject>

class ComponentsCommonConfiguration : public QObject
{
    Q_OBJECT
public:
    explicit ComponentsCommonConfiguration(QObject *parent = nullptr);

    void setRootDir(const QString& rootDir);
    QString getRootDir() const;

    void setInstallPath(const QString& instPath);
    QString getInstallPath() const;

    void setCppStandard(int standardNumber);
    int getCppStandard() const;

    void setCMakeVersion(int vers); // Version is like 13.724 --> 13724
    int getCMakeVersion() const;

signals:
    void sig_rootDirChanged();
    void sig_installPathChanged();
    void sig_cppStandardChanged();
    void sig_cmakeVersionChanged();

private:
    QString m_rootDir;
    QString m_installDir;

    int m_cppStandard {-1};
    int m_cmakeVersion {-1};
};
