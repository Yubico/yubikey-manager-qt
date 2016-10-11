#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
#include <QtWidgets>
#include <QtSingleApplication>

int main(int argc, char *argv[])
{
    // Only allow a single instance running.
    QtSingleApplication app(argc, argv);
    if (app.sendMessage("")) {
        return 0;
    }

    QQmlApplicationEngine engine;
    app.setWindowIcon(QIcon("resources/icons/ykman.png"));
    QString pythonNoBytecode = "PYTHONDONTWRITEBYTECODE=1";
    putenv(pythonNoBytecode.toUtf8().data());
    QString frameworks = "DYLD_LIBRARY_PATH=" + app.applicationDirPath() + "/../Frameworks";
    putenv(frameworks.toUtf8().data());
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

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

    return app.exec();
}
