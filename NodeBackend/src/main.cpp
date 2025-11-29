#include <QCoreApplication>
#include <QDebug>
#include <QEventLoop>
#include <QObject>
#include <QTcpServer>
#include <QTimer>
#include <QUuid>
#include <filesystem>
#include <qlogging.h>
#include <qmap.h>
#include <qobject.h>
#include <string>

#include "ManagementNotifier.h"
#include "MinecraftInstance.h"

using namespace std;

bool isPortAvailable(quint16 port);

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  QEventLoop loop;

  ManagementNotifier *mngr = new ManagementNotifier(nullptr);

  QMap<string, MinecraftInstance *> instances;

  QObject::connect(mngr, &ManagementNotifier::connected, [&]() {});
  QObject::connect(mngr, &ManagementNotifier::disconnected, [&]() {});
  QObject::connect(mngr, &ManagementNotifier::serverCreateReceived,
                   [&](std::string worldId, std::string config) {
                     filesystem::path worldPath =
                         filesystem::path("/srv/tepor/worlds") / worldId;

                     if (!filesystem::exists(worldPath)) {
                       filesystem::create_directories(worldPath);
                     }

                     int port = 25565;
                     while (!isPortAvailable(port)) {
                       port++;

                       if (port > 65535) {
                         qCritical() << "No free port found";
                         return;
                       }
                     }

                     instances.insert(worldId, new MinecraftInstance(
                                                   worldId, config,
                                                   worldPath.string(), port));
                   });

  QObject::connect(mngr, &ManagementNotifier::serverStartReceived,
                   [&](std::string worldId) {
                     if (instances.contains(worldId)) {
                       instances[worldId]->start();
                     }
                   });

  QObject::connect(mngr, &ManagementNotifier::serverStopReceived,
                   [&](std::string worldId) {
                     if (instances.contains(worldId)) {
                       instances[worldId]->stop();
                     }
                   });

  QObject::connect(mngr, &ManagementNotifier::serverRestartReceived,
                   [&](std::string worldId) {
                     if (instances.contains(worldId)) {
                       instances[worldId]->restart();
                     }
                   });

  QObject::connect(mngr, &ManagementNotifier::serverDeleteReceived,
                   [&](std::string worldId) {
                     if (instances.contains(worldId)) {
                       instances[worldId]->deleteWorld();
                       instances.remove(worldId);
                     }
                   });

  QObject::connect(mngr, &ManagementNotifier::updateConfigReceived,
                   [&](std::string worldId, std::string config) {
                     if (instances.contains(worldId)) {
                       instances[worldId]->updateConfig(config);
                     }
                   });

  QObject::connect(mngr, &ManagementNotifier::errorOccurred,
                   [&](const QString &error) {
                     qCritical() << error;
                     loop.quit();
                   });

  QObject::connect(mngr, &ManagementNotifier::registered, [&]() {});

  loop.exec();

  delete mngr;

  return 0;
}

bool isPortAvailable(quint16 port) {
  QTcpServer server;
  bool success = server.listen(QHostAddress::Any, port);
  server.close();
  return success;
}
