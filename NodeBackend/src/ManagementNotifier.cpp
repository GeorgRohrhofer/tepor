#include "ManagementNotifier.h"

#include <nlohmann/json.hpp>
#include <qtmetamacros.h>

using json = nlohmann::json;

ManagementNotifier::ManagementNotifier(QObject *parent) : QObject(parent) {
  nm = new NetworkManager(this);

  connect(nm, &NetworkManager::connected, this,
          &ManagementNotifier::onConnected);
  connect(nm, &NetworkManager::disconnected, this,
          &ManagementNotifier::onDisconnected);
  connect(nm, &NetworkManager::messageReceived, this,
          &ManagementNotifier::onMessageReceived);
  connect(nm, &NetworkManager::errorOccurred, this,
          &ManagementNotifier::onErrorOccurred);
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

  // TODO: check if message is valid
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
      emit registered();
    }
  }
}

void ManagementNotifier::onErrorOccurred(const QString &error) {
  emit errorOccurred(error);
}
