#include "ManagementNotifier.h"

#include <nlohmann/json.hpp>
#include <qtmetamacros.h>

using json = nlohmann::json;

ManagementNotifier::ManagementNotifier(QObject *parent, QString host,
                                       quint16 port, DatabaseManager *db)
    : QObject(parent) {
  nm = new NetworkManager(this);
  this->db = db;

  connect(nm, &NetworkManager::connected, this,
          &ManagementNotifier::onConnected);
  connect(nm, &NetworkManager::disconnected, this,
          &ManagementNotifier::onDisconnected);
  connect(nm, &NetworkManager::messageReceived, this,
          &ManagementNotifier::onMessageReceived);
  connect(nm, &NetworkManager::errorOccurred, this,
          &ManagementNotifier::onErrorOccurred);

  nm->connectToServer(host, port);
}

ManagementNotifier::~ManagementNotifier() { delete nm; }

void ManagementNotifier::onConnected() {
  qDebug() << "Connected to server";
  emit connected();
}

void ManagementNotifier::onDisconnected() {
  qDebug() << "Disconnected from server";
  emit disconnected();
}

void ManagementNotifier::onMessageReceived(const QByteArray &data) {
  qDebug() << "Received message: " << QString(data);

  try {
    json message = json::parse(data);
    if (message.contains("type")) {
      if (message["type"] == "ServerCreate") {
        std::string world_id = message["data"]["world_id"];
        std::string config = message["data"]["config"];

        emit serverCreateReceived(world_id, config);
      } else if (message["type"] == "ServerStart") {
        std::string world_id = message["data"]["world_id"];

        emit serverStartReceived(world_id);
      } else if (message["type"] == "ServerStop") {
        std::string world_id = message["data"]["world_id"];

        emit serverStopReceived(world_id);
      } else if (message["type"] == "ServerRestart") {
        std::string world_id = message["data"]["world_id"];

        emit serverRestartReceived(world_id);
      } else if (message["type"] == "ServerDelete") {
        std::string world_id = message["data"]["world_id"];

        emit serverDeleteReceived(world_id);
      } else if (message["type"] == "UpdateConfig") {
        std::string world_id = message["data"]["world_id"];
        std::string config = message["data"]["config"];

        emit updateConfigReceived(world_id, config);
      } else if (message["type"] == "VERSION_ERROR") {
        emit errorOccurred("Version mismatch");
      } else if (message["type"] == "HELOResp") {
        activeId = message["data"]["active_id"];
        emit registered(activeId);
      }
    }
  } catch (json::parse_error &e) {
    qFatal() << "Error parsing message: " << e.what();
  }
}

void ManagementNotifier::onErrorOccurred(const QString &error) {
  emit errorOccurred(error);
}

void ManagementNotifier::sendWorldSaved(std::string worldName,
                                        std::string hash) {
  json message = {{"type", "WorldSaved"},
                  {"data", {{"world_id", worldName}}},
                  {"hash", hash}};

  nm->sendMessage(QByteArray(message.dump()));
}

void ManagementNotifier::sendRegister(QUuid uuid) {
  json message = {{"type", "HELOReq"},
                  {"data", {{"previous_id", uuid.toString().toStdString()}}}};

  nm->sendMessage(QByteArray(message.dump()));
}
