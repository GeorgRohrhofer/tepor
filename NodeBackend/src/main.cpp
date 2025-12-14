#include <CLI/CLI.hpp>
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
#include <qtypes.h>
#include <string>
#include <sys/types.h>
#include <unistd.h>

#include "DatabaseManager.h"
#include "ManagementNotifier.h"
#include "MinecraftInstance.h"

using namespace std;

bool isPortAvailable(quint16 port);
void startMonitoringClient(string monitorExe, string nodeId, string MonServerIp, qint16 port);

int main(int argc, char *argv[]) {
  //----------------------------------------------------------------------------
  // CLI setup
  //----------------------------------------------------------------------------
  CLI::App cliApp{"NodeBackend"};

  string dbPath = "/flyway/sqlite.db";
  cliApp.add_option("-d, --database", dbPath, "Path to the sqlite database");

  string host = "localhost";
  cliApp.add_option("-t, --host", host, "Host to connect to");

  quint16 port = 8000;
  cliApp.add_option("-p, --port", port, "Port to connect to");

  string monitorExe = "/srv/tepor/MonitoringClient";
  cliApp.add_option("-e, --monitor-exe", monitorExe,
      "Path to the monitoring client executable");

  string monitorIp = "monitor.tepor.at";
  cliApp.add_option("-i, --monitor-ip", monitorIp,
      "IP to connect the monitoring client to");

  quint16 monitorPort = 6942;
  cliApp.add_option("-m, --monitor-port", monitorPort,
                    "Port to connect the monitoring client to");


  CLI11_PARSE(cliApp, argc, argv);

  //----------------------------------------------------------------------------

  QCoreApplication app(argc, argv);
  QEventLoop loop;
  DatabaseManager *db = new DatabaseManager(QString::fromStdString(dbPath));

  try {
    db->executeCommand(
        "CREATE TABLE World (id INTEGER, name TEXT, hash TEXT, config TEXT)");
    db->executeCommand("CREATE TABLE Node (id INTEGER)");
    db->executeCommand("INSERT INTO Node (id) VALUES ('" +
                       QUuid::createUuid().toString(QUuid::WithoutBraces) +
                       "')");
  } catch (const std::runtime_error &e) {
    // Database setup has already been ran once
  }

  ManagementNotifier *mngr =
      new ManagementNotifier(nullptr, QString::fromStdString(host), port, db);

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

  QObject::connect(mngr, &ManagementNotifier::registered, [&](string activeId) {
    QString activeIdQString = QString::fromStdString(activeId);
    db->executeCommand("UPDATE Node SET id = '" + activeIdQString + "'");

    startMonitoringClient(monitorExe, activeId, monitorIp, monitorPort);
  });

  mngr->sendRegister(
      QUuid(db->executeQuery("SELECT id FROM Node")[0]["id"].toString()));
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

void startMonitoringClient(string monitorExe, string nodeId, string MonServerIp, qint16 port) {
  pid_t pid = fork();
  if (pid == 0) {
    execl(monitorExe.c_str(), "MonitoringClient", "--ipaddress",
          MonServerIp.c_str(), "--port", port, "--nodeid", nodeId.c_str(),
          NULL);

    qCritical() << "Error starting monitoring client";
    exit(1);
  } else if (pid > 0) {
    qInfo() << "Monitoring client started with PID: " << pid;
  } else {
    qCritical() << "Fork failed";
  }
}
