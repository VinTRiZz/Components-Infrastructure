#include "componentmodel.hpp"

#include <QFileSystemWatcher>
#include <QDir>

#include <Components/Logger/Logger.h>

#include "objects/mastercomponent.hpp"

ComponentModel::ComponentModel(ComponentsCommonConfiguration *pConfig, QObject *parent) :
    QAbstractTableModel{parent},
    m_pConfig {pConfig}
{
    if (nullptr == pConfig) {
        throw std::invalid_argument("ComponentModel: Invalid config (nullptr)");
    }
    connect(m_pConfig, &ComponentsCommonConfiguration::sig_rootDirChanged,
            this, [this](){ setRoot(m_pConfig->getRootDir()); });

    m_pFsWatcher = new QFileSystemWatcher(this);
    connect(m_pFsWatcher, &QFileSystemWatcher::directoryChanged,
            this, &ComponentModel::updateComponentList);
}

void ComponentModel::setRoot(const QString &rootDir)
{
    auto dirs = m_pFsWatcher->directories();
    if (!dirs.isEmpty()) {
        m_pFsWatcher->removePaths(dirs);
    }
    m_pFsWatcher->addPath(rootDir);
    updateComponentList(rootDir);
}

MasterComponent *ComponentModel::getComponent(int row) const
{
    if (row < 0 || row >= m_components.size()) {
        return {};
    }

    auto targetComponent = m_components.begin();
    std::advance(targetComponent, row);
    return targetComponent->second;
}

MasterComponent *ComponentModel::getComponent(const QModelIndex &idx) const
{
    return getComponent(idx.row());
}

QModelIndex ComponentModel::getComponentIndex(const QString &componentName) const
{
    auto targetIt = m_components.find(componentName);
    if (m_components.end() == targetIt) {
        return {};
    }
    return createIndex(std::distance(m_components.begin(), targetIt), 0, nullptr);
}

QModelIndex ComponentModel::getComponentIndex(MasterComponent *pComponent) const
{
    if (pComponent) {
        return getComponentIndex(pComponent->getName());
    }
    return {};
}

int ComponentModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_components.size();
}

int ComponentModel::columnCount([[maybe_unused]] const QModelIndex &parent) const
{
    return 1;
}

QVariant ComponentModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) { return {}; }
    auto pComponent = getComponent(index);
    if (!pComponent) { return {}; }

    switch (role)
    {
    case Qt::DisplayRole: return pComponent->getName();
    case Qt::ToolTipRole: return QString("Component [ %2 ]").arg(pComponent->getName());
    }

    if (role > Qt::UserRole) {
        switch (role)
        {
        case R_PComponent: return QVariant::fromValue(getComponent(index));
        }
    }
    return {};
}

void ComponentModel::updateComponentList(const QString& dirPath)
{
    auto watchDir = QDir(dirPath);
    auto entries = watchDir.entryList(QDir::NoFilter, QDir::Name);
    entries.erase(std::remove_if(entries.begin(), entries.end(), [&watchDir](auto& entry) {
                      auto fInfo = QFileInfo(watchDir.absoluteFilePath(entry));
                      return (!fInfo.isDir() || !fInfo.isReadable() || (entry == "." || entry == ".."));
                  }),
                  entries.end());

    MasterComponent* pComponent {nullptr};

    int insertionRow {};
    for (auto& entr : entries) {
        if (m_lastDirectoryList.contains(entr)) { continue; }

        // Memory optimisation
        if (!pComponent) {
            pComponent = new MasterComponent(this);
            pComponent->setCommonConfig(m_pConfig);
        }
        if (!pComponent->setName(entr)) {
            continue;
        }

        beginInsertRows(QModelIndex(), insertionRow, insertionRow);
        m_lastDirectoryList.insert(insertionRow, entr);
        ++insertionRow;
        m_components.emplace(entr, pComponent);
        pComponent = nullptr;
        endInsertRows();
    }
    if (pComponent) { delete pComponent; }

    for (auto& entr : m_lastDirectoryList) {
        if (entries.contains(entr)) { continue; }

        auto targetIt = m_components.find(entr);
        auto componentRow = std::distance(m_components.begin(), targetIt);
        beginRemoveRows(QModelIndex(), componentRow, componentRow);
        targetIt->second->deleteLater();
        m_components.erase(targetIt);
        endRemoveRows();
    }
}
