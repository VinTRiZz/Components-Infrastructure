#pragma once

#include <QString>
#include <QVariant>

#include <unordered_map>

#include "cmakeaction.hpp"

class CMakeSwitch
{
public:
    void setName(const QString& switchName);

    void setCompareValue(const QVariant& val);

    void setEnabledAction(CMakeAction&& act);
    void setDisabledAction(CMakeAction&& act);

    QByteArray toCMakeText() const;

private:
    QString m_name;
    QVariant m_compareValue;

    CMakeAction m_onTrue;
    CMakeAction m_onFalse;
};
