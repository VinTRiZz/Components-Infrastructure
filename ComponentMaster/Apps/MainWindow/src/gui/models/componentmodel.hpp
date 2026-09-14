#pragma once

#include <QIdentityProxyModel>

#include <map>

#include "objects/mastercomponent.hpp"

class QFileSystemWatcher;
class ComponentsCommonConfiguration;

class ComponentModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    explicit ComponentModel(ComponentsCommonConfiguration* pConfig, QObject *parent = nullptr);

    void setRoot(const QString& rootDir);

    enum Roles : int
    {
        R_PComponent = Qt::UserRole + 1,
    };

    bool addComponent(MasterComponent* pComponent);
    bool addComponent(const QString& name);
    bool removeComponent(MasterComponent* pComponent);
    bool removeComponent(const QString& name);
    MasterComponent* getComponent(int row) const;
    MasterComponent* getComponent(const QModelIndex& idx) const;
    QModelIndex getComponentIndex(const QString& componentName) const;
    QModelIndex getComponentIndex(MasterComponent* pComponent) const;

    // Reimplemented to hide subdirs of root
    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    QFileSystemWatcher* m_pFsWatcher {nullptr};

    ComponentsCommonConfiguration* m_pConfig {nullptr};

    QStringList m_lastDirectoryList;
    std::map<QString, MasterComponent*> m_components;

    void updateComponentList(const QString &dirPath);
};


Q_DECLARE_METATYPE(MasterComponent*);
