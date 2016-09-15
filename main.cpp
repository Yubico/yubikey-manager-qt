#include <QApplication>
#include <QQmlApplicationEngine>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    //Set DYLD_LIBRARY_PATH to exe_dir/lib/
    char* base_dir = app.applicationDirPath().toLatin1().data();
    char dyld_path[sizeof(base_dir) + 4];
    strcpy(dyld_path, base_dir);
    strcat(dyld_path, "/lib");
    setenv("DYLD_LIBRARY_PATH", dyld_path, 1);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
