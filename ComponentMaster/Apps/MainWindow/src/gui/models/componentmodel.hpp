#pragma once

#include <QIdentityProxyModel>

#include "objects/mastercomponent.hpp"

class QFileSystemModel;

class ComponentModel : public QIdentityProxyModel
{
    Q_OBJECT

    using QIdentityProxyModel::setSourceModel;
    using QIdentityProxyModel::sourceModel;

public:
    explicit ComponentModel(QObject *parent = nullptr);

    void setRoot(const QString& rootDir);

    MasterComponent* getComponent(int row) const;
    MasterComponent* getComponent(const QModelIndex& idx) const;

private:
    QFileSystemModel* m_pFsModel {nullptr};

    std::vector<MasterComponent*> m_components;
};
