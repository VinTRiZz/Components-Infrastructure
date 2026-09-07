#include "mastersystem.hpp"

#include <QDir>

#include "../mastermanifest/mastermanifest.hpp"

MasterSystem::MasterSystem(QObject *parent)
    : QObject{parent}
{
    m_pManifest = new MasterManifest(this);
}

void MasterSystem::setDir(const QString &sysDir)
{
    m_dir = sysDir;

    // Update paths
    m_pManifest->setTargetFile(m_dir + QDir::separator() + "manifest.ini");
}

bool MasterSystem::init()
{
    if (!m_pManifest->init()) {
        return false;
    }

    return true;
}
