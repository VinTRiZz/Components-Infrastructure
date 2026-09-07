#include "componentscommonconfiguration.hpp"

ComponentsCommonConfiguration::ComponentsCommonConfiguration(QObject *parent)
    : QObject{parent}
{

}

void ComponentsCommonConfiguration::setRootDir(const QString &rootDir)
{
    m_rootDir = rootDir;
    emit sig_rootDirChanged();
}

QString ComponentsCommonConfiguration::getRootDir() const
{
    return m_rootDir;
}

void ComponentsCommonConfiguration::setInstallPath(const QString &instPath)
{
    m_installDir = instPath;
    emit sig_installPathChanged();
}

QString ComponentsCommonConfiguration::getInstallPath() const
{
    return m_installDir;
}

void ComponentsCommonConfiguration::setCppStandard(int standardNumber)
{
    m_cppStandard = standardNumber;
    emit sig_cppStandardChanged();
}

int ComponentsCommonConfiguration::getCppStandard() const
{
    return m_cppStandard;
}

void ComponentsCommonConfiguration::setCMakeVersion(int vers)
{
    m_cmakeVersion = vers;
    emit sig_cmakeVersionChanged();
}

int ComponentsCommonConfiguration::getCMakeVersion() const
{
    return m_cmakeVersion;
}
