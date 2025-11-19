#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QCoreApplication>
#include "CubeProgrammerInterface.h"
#include <QDebug>
#include "DisplayManager.h"

extern unsigned int verbosityLevel;

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;


    CubeProgrammerInterface programmerInterface;
    engine.rootContext()->setContextProperty("programmerInterface", &programmerInterface);

    bool isConnected = false;
    engine.rootContext()->setContextProperty("isConnected", isConnected);

    QString executableDir = QCoreApplication::applicationDirPath();


    QString loaderPath = executableDir + "/../FlashLoader";

    qDebug() << "Resolved FlashLoader path:" << loaderPath;

    setLoadersPath(loaderPath.toStdString().c_str());
    displayCallBacks vsLogMsg;
    vsLogMsg.logMessage = DisplayMessage;
    vsLogMsg.initProgressBar = InitPBar;
    vsLogMsg.loadBar = lBar;

    setDisplayCallbacks(vsLogMsg);

    setVerbosityLevel(verbosityLevel = VERBOSITY_LEVEL_1);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
