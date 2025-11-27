#include <QCoreApplication>
#include <QDebug>
#include <QEventLoop>
#include <QObject>
#include <QTimer>
#include <QUuid>
#include <iostream>
#include <qlogging.h>
#include <qmap.h>
#include <qobject.h>
#include <string>

#include "ManagementNotifier.h"
#include "MinecraftInstance.h"
#include "NetworkManager.h"

using namespace std;

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  QEventLoop loop;

  // NetworkManager *mng = new NetworkManager(nullptr);
  // QObject::connect(mng, &NetworkManager::messageReceived, [&](QByteArray
  // data) {
  //   cout << QString(data).toStdString() << endl;
  //   loop.quit();
  // });
  //
  // mng->connectToServer("localhost", 8080);
  // mng->waitForConnection();
  // mng->sendMessage("test");

  ManagementNotifier *mngr = new ManagementNotifier(nullptr);

  QMap<string, MinecraftInstance *> instances;

  QObject::connect(mngr, &ManagementNotifier::connected, [&]() {});
  QObject::connect(mngr, &ManagementNotifier::disconnected, [&]() {});
  QObject::connect(mngr, &ManagementNotifier::serverCreateReceived,
                   [&](std::string worldId, std::string config) {
                     // TODO: Generate file path for each world
                     instances.insert(
                         worldId, new MinecraftInstance(worldId, config, "/"));
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
