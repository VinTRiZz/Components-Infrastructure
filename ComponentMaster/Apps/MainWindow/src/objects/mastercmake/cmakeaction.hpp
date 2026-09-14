#pragma once

#include <QString>

class CMakeAction
{
public:
    bool isValid() const;

private:
    bool m_isValid {false};
};
