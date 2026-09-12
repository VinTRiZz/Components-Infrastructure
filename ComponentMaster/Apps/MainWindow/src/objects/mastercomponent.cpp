#include "mastercomponent.hpp"

#include <QDir>

#include <Components/Logger/Logger.h>

#include "mastersystem/mastersystem.hpp"

MasterComponent::MasterComponent(QObject *parent) :
    QObject{parent},
    m_pSystem {new MasterSystem(this)}
{

}

void MasterComponent::setCommonConfig(ComponentsCommonConfiguration* pConfig)
{
    m_pConfig = pConfig;

    // TODO: Process signals
}

bool MasterComponent::init()
{
    return false;
}

bool MasterComponent::setName(const QString &compName)
{
    if (compName.contains(QDir::separator())) {
        COMPLOG_ERROR("MasterComponent: Invalid component name (ignored):", m_name.toStdString());
        return false;
    }
    m_name = compName;

    processNameChange();
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

void MasterComponent::processNameChange()
{
    m_pSystem->setDir(getRootPath());
}