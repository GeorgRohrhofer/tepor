#include "MinecraftInstance.h"

#include <QDebug>
#include <QFileSystemWatcher>
#include <filesystem>
#include <fstream>
#include <string>

int MinecraftInstance::instanceCount = 0;
Docker *MinecraftInstance::docker = nullptr;

MinecraftInstance::MinecraftInstance(std::string worldId, std::string config,
                                     std::string worldStore, int port) {
  this->worldId = worldId;
  this->config = config;
  this->worldStore = worldStore;

  if (docker == nullptr) {
    docker = new Docker();
  }

  // TODO: Add file mapping
  containerId = docker->createContainer(
      "marctv/minecraft-papermc-server:1.21.10-91", worldId, {},
      {{"25565", std::to_string(port)}}, {{worldStore, "/data"}});
  instanceCount++;

  watcher = new QFileSystemWatcher(this);
  QObject::connect(watcher, &QFileSystemWatcher::directoryChanged,
                   [&](QString path) { onFilesChanged(path); });
}

MinecraftInstance::~MinecraftInstance() {
  instanceCount--;

  if (instanceCount == 0) {
    delete docker;
    docker = nullptr;
  }

  delete watcher;
}

std::string MinecraftInstance::GetWorldId() { return worldId; }

std::string MinecraftInstance::GetConfig() { return config; }

std::string MinecraftInstance::GetWorldStore() { return worldStore; }

std::string MinecraftInstance::GetContainerId() { return containerId; }

void MinecraftInstance::start() { docker->startContainer(containerId); }

void MinecraftInstance::stop() { docker->stopContainer(containerId); }

void MinecraftInstance::restart() { docker->restartContainer(containerId); }

void MinecraftInstance::deleteWorld() {
  docker->removeContainer(containerId);
  std::filesystem::remove_all(worldStore);
}

void MinecraftInstance::updateConfig(std::string config) {
  this->config = config;

  std::string configPath =
      std::filesystem::path(worldStore) / "server.properties";

  std::ofstream configFile(configPath, std::ios::trunc);

  if (!configFile.is_open()) {
    qCritical() << "Failed to open config file";
    return;
  }

  configFile << config;
  configFile.close();

  qInfo() << "Config has been updated";
  qInfo() << "Restarting Minecraft Server now";
  restart();
}

void MinecraftInstance::onFilesChanged(QString path) {
  qDebug() << "Files changed: " << path;
  emit wordSaved();
}
