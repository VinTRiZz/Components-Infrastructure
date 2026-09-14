#include "mastercomponent.hpp"

#include <QDir>

#include <Components/Logger/Logger.h>

#include "mastersystem/mastersystem.hpp"
#include "mastercmake/mastercmake.hpp"

MasterComponent::MasterComponent(QObject *parent) :
    QObject{parent},
    m_pSystem {new MasterSystem(this)},
    m_pCMake {new MasterCMake(this)}
{

}

void MasterComponent::setCommonConfig(ComponentsCommonConfiguration* pConfig)
{
    m_pConfig = pConfig;

    // TODO: Process signals
}

bool MasterComponent::migrateComponent()
{
    COMPLOG_INFO("Migrating component:", getName().toStdString());

    m_pSystem->setDir(getRootPath());
    if (!m_pSystem->migrate()) { return false; }

    m_pCMake->setTargetFile(getRootPath() + QDir::separator() + "CMakeLists.txt");
    if (!m_pCMake->readTarget()) { return false; }
    if (!m_pCMake->writeChanges()) { return false; }

    COMPLOG_OK("Migrated component:", getName().toStdString());
    return true;
}

bool MasterComponent::setupComponent()
{
    COMPLOG_INFO("Configured component:", getName().toStdString());
    return false;
}

bool MasterComponent::readComponent()
{
    COMPLOG_INFO("Reading component:", getName().toStdString());

    m_pSystem->setDir(getRootPath());
    if (!m_pSystem->init()) { return false; }

    m_pCMake->setTargetFile(getRootPath() + QDir::separator() + "CMakeLists.txt");
    if (!m_pCMake->readTarget()) { return false; }

    COMPLOG_OK("Inited component:", getName().toStdString());
    return true;
}

void MasterComponent::deleteComponent()
{
    QDir(getRootPath()).removeRecursively();
    COMPLOG_INFO("Removed component:", getName().toStdString());
}

bool MasterComponent::setName(const QString &compName)
{
    if (compName.contains(QDir::separator())) {
        COMPLOG_ERROR("MasterComponent: Invalid component name (ignored):", m_name.toStdString());
        return false;
    }
    m_name = compName;
    return true;
}

QString MasterComponent::getName() const
{
    return m_name;
}

QString MasterComponent::getRootPath() const
{
    if (m_pConfig) {
        return m_pConfig->getRootDir() + QDir::separator() + m_name;
    }
    return m_name;
}