#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
#include <QtWidgets>
#include <QtSingleApplication>

int main(int argc, char *argv[])
{
    #if QT_VERSION >= QT_VERSION_CHECK(5, 6, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    #endif

    // Non Darwin platforms uses QSingleApplication to ensure only one running instance.
    #ifndef Q_OS_DARWIN
    QtSingleApplication app(argc, argv);
    if (app.sendMessage("")) {
        return 0;
    }
    #else
    QApplication app(argc, argv);
    #endif

    app.setOrganizationName("Yubico");
    app.setApplicationName("YubiKey Manager");
    app.setApplicationDisplayName("YubiKey Manager");
    app.setApplicationVersion("0.2.0");

    qputenv("PYTHONDONTWRITEBYTECODE", "1");

    app.setWindowIcon(QIcon("resources/icons/ykman.png"));
    app.setOrganizationName("Yubico");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    #ifndef Q_OS_DARWIN
    // Wake up the root window on a message from new instance.
    for (auto object : engine.rootObjects()) {
        if (QWindow *window = qobject_cast<QWindow*>(object)) {
            QObject::connect(&app, &QtSingleApplication::messageReceived, [window]() {
                window->show();
                window->raise();
                window->requestActivate();
            });
        }
    }
    #endif

    return app.exec();
}
