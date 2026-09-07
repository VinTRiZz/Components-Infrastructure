#include "componentmodel.hpp"

#include <QFileSystemModel>

ComponentModel::ComponentModel(QObject *parent)
    : QIdentityProxyModel{parent}
{
    m_pFsModel = new QFileSystemModel(this);
    setSourceModel(m_pFsModel);
}

void ComponentModel::setRoot(const QString &rootDir)
{
    m_pFsModel->setRootPath(rootDir);
}

MasterComponent *ComponentModel::getComponent(int row) const
{

}

MasterComponent *ComponentModel::getComponent(const QModelIndex &idx) const
{

}
