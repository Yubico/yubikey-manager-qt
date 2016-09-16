#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>
#include <QtGlobal>
int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    setenv("PYTHONDONTWRITEBYTECODE", "1", 1);
    QString frameworks = app.applicationDirPath() + "/../Frameworks";
    setenv("DYLD_LIBRARY_PATH", frameworks.toUtf8().data(), 1);

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
