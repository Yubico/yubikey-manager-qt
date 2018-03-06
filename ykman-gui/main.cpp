#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
#include <QtWidgets>

int main(int argc, char *argv[])
{
    // Global menubar is broken for qt5 apps in Ubuntu Unity, see:
    // https://bugs.launchpad.net/ubuntu/+source/appmenu-qt5/+bug/1323853
    // This workaround enables a local menubar.
    qputenv("UBUNTU_MENUPROXY","0");

    // Don't write .pyc files.
    qputenv("PYTHONDONTWRITEBYTECODE", "1");

    QApplication app(argc, argv);

    QString app_dir = app.applicationDirPath();
    QString main_qml = "/qml/main.qml";
    QString path_prefix;
    QString url_prefix;

    app.setApplicationName("YubiKey Manager");
    app.setOrganizationName("Yubico");
    app.setOrganizationDomain("com.yubico");

    // A lock file is used, to ensure only one running instance at the time.
    QString tmpDir = QDir::tempPath();
    QLockFile lockFile(tmpDir + "/ykman-gui.lock");
    if(!lockFile.tryLock(100)) {
        QMessageBox msgBox;
        msgBox.setIcon(QMessageBox::Warning);
        msgBox.setText("YubiKey Manager is already running.");
        msgBox.exec();
        return 1;
    }

    if (QFileInfo::exists(":" + main_qml)) {
        // Embedded resources
        path_prefix = ":";
        url_prefix = "qrc://";
    } else if (QFileInfo::exists(app_dir + main_qml)) {
        // Try relative to executable
        path_prefix = app_dir;
        url_prefix = app_dir;
    } else {  //Assume qml/main.qml in cwd.
        app_dir = ".";
        path_prefix = ".";
        url_prefix = ".";
    }

    app.setWindowIcon(QIcon(path_prefix + "/images/windowicon.png"));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appDir", app_dir);
    engine.rootContext()->setContextProperty("urlPrefix", url_prefix);
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION);

    engine.load(QUrl(url_prefix + main_qml));

    if (argc > 2 && strcmp(argv[1], "--log-level") == 0) {
        if (argc > 4 && strcmp(argv[3], "--log-file") == 0) {
            QMetaObject::invokeMethod(engine.rootObjects().first(), "enableLoggingToFile", Q_ARG(QVariant, argv[2]), Q_ARG(QVariant, argv[4]));
        } else {
            QMetaObject::invokeMethod(engine.rootObjects().first(), "enableLogging", Q_ARG(QVariant, argv[2]));
        }
    } else {
        QMetaObject::invokeMethod(engine.rootObjects().first(), "disableLogging");
    }

    return app.exec();
}
