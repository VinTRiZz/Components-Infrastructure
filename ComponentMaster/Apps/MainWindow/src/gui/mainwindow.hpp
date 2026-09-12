#pragma once

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class ComponentModel;
class ComponentsCommonConfiguration;
class MasterComponent;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;

    ComponentModel* m_pComponentModel {nullptr};

    ComponentsCommonConfiguration* m_pCommonConfig {nullptr};
    MasterComponent* m_pComponent {nullptr};
};
