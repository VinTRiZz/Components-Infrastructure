#include "cmakeswitch.hpp"


void CMakeSwitch::setName(const QString &switchName)
{
    m_name = switchName;
}

void CMakeSwitch::setEnabledAction(CMakeAction &&act)
{
    m_onTrue = std::move(act);
}

void CMakeSwitch::setDisabledAction(CMakeAction &&act)
{
    m_onFalse = std::move(act);
}

QByteArray CMakeSwitch::toCMakeText() const
{
    QByteArray res;

    if (m_compareValue.isNull()) {
        COMPLOG_WARNING("Invalid (NULL) compare value for switch", m_name.toStdString());
        return {};
    }

    if (m_compareValue.canConvert<bool>()) {
        res += QString("if(%1 == %2)").arg(m_name, (m_compareValue.toBool() ? "ON" : "OFF")).toUtf8();
    } else if (m_compareValue.canConvert<uint>()) {
        res += QString("if(%1 == %2)").arg(m_name, m_compareValue.toString()).toUtf8();
    } else {
        res += QString("if(%1 STREQUAL \"%2\")").arg(m_name, m_compareValue.toString()).toUtf8();
    }

    return res;
}
