#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
#include <QtWidgets>
#include <QtSingleApplication>

int main(int argc, char *argv[])
{
    QtSingleApplication app(argc, argv);
    if (app.isRunning()) {
        return 0;
    }
    QQmlApplicationEngine engine;
    app.setWindowIcon(QIcon("resources/icons/ykman.png"));
    QString pythonNoBytecode = "PYTHONDONTWRITEBYTECODE=1";
    putenv(pythonNoBytecode.toUtf8().data());
    QString frameworks = "DYLD_LIBRARY_PATH=" + app.applicationDirPath() + "/../Frameworks";
    putenv(frameworks.toUtf8().data());
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    return app.exec();
}
