#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
#include <QtWidgets>

int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    app.setWindowIcon(QIcon("resources/icons/ykman.png"));
    QString pythonNoBytecode = "PYTHONDONTWRITEBYTECODE=1";
    putenv(pythonNoBytecode.toUtf8().data());
    QString frameworks = "DYLD_LIBRARY_PATH=" + app.applicationDirPath() + "/../Frameworks";
    putenv(frameworks.toUtf8().data());

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
