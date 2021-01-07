#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <signal.h>
#include <QtGlobal>
#include <QtWidgets>
#include <QQuickStyle>

void handleExitSignal(int sig) {
  printf("Exiting due to signal %d\n", sig);
  QCoreApplication::quit();
}

void setupSignalHandlers() {
#ifdef _WIN32
  signal(SIGINT, handleExitSignal);
#else
  struct sigaction sa;
  sa.sa_handler = handleExitSignal;
  sigset_t signal_mask;
  sigemptyset(&signal_mask);
  sa.sa_mask = signal_mask;
  sa.sa_flags = 0;
  sigaction(SIGINT, &sa, nullptr);
#endif
}

int main(int argc, char *argv[])
{
    setupSignalHandlers();

    // Global menubar is broken for qt5 apps in Ubuntu Unity, see:
    // https://bugs.launchpad.net/ubuntu/+source/appmenu-qt5/+bug/1323853
    // This workaround enables a local menubar.
    qputenv("UBUNTU_MENUPROXY","0");

    // Don't write .pyc files.
    qputenv("PYTHONDONTWRITEBYTECODE", "1");

    QApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    QString app_dir = app.applicationDirPath();
    QString main_qml = "/qml/main.qml";
    QString path_prefix;
    QString url_prefix;

    app.setApplicationName("YubiKey Manager");
    app.setApplicationVersion(APP_VERSION);
    app.setOrganizationName("Yubico");
    app.setOrganizationDomain("org.yubico");

    // Workaround for https://bugreports.qt.io/browse/QTBUG-66915
    // Fixing 64bit builds on Windows
    app.setAttribute(Qt::AA_DisableShaderDiskCache);

    QCommandLineParser cliParser;
    cliParser.setApplicationDescription("Configure your YubiKey using a graphical application.");
    cliParser.addHelpOption();
    cliParser.addVersionOption();
    cliParser.addOptions({
        {"log-level", QCoreApplication::translate("main", "Enable logging at verbosity <LEVEL>: DEBUG, INFO, WARNING, ERROR, CRITICAL"), QCoreApplication::translate("main", "LEVEL")},
        {"log-file", QCoreApplication::translate("main", "Print logs to <FILE> instead of standard output; ignored without --log-level"), QCoreApplication::translate("main", "FILE")},
    });

    cliParser.process(app);

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
    // TODO: Fix pymodulesDir so it works on non-mac as well.
    engine.rootContext()->setContextProperty("pymodulesDir", app_dir + "/../Resources/pymodules");
    engine.rootContext()->setContextProperty("urlPrefix", url_prefix);
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION);

    engine.load(QUrl(url_prefix + main_qml));

    if (cliParser.isSet("log-level")) {
        if (cliParser.isSet("log-file")) {
            QMetaObject::invokeMethod(engine.rootObjects().first(), "enableLoggingToFile", Q_ARG(QVariant, cliParser.value("log-level")), Q_ARG(QVariant, cliParser.value("log-file")));
        } else {
            QMetaObject::invokeMethod(engine.rootObjects().first(), "enableLogging", Q_ARG(QVariant, cliParser.value("log-level")));
        }
    } else {
        QMetaObject::invokeMethod(engine.rootObjects().first(), "disableLogging");
    }

    return app.exec();
}
