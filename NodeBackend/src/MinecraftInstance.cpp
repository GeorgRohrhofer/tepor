#include "MinecraftInstance.h"

#include <QDebug>
#include <string>

int MinecraftInstance::instanceCount = 0;
Docker *MinecraftInstance::docker = nullptr;

MinecraftInstance::MinecraftInstance(std::string worldId, std::string config,
                                     std::string worldStore) {
  this->worldId = worldId;
  this->config = config;
  this->worldStore = worldStore;

  if (docker == nullptr) {
    docker = new Docker();
  }

  instanceCount++;
}

MinecraftInstance::~MinecraftInstance() {
  instanceCount--;

  if (instanceCount == 0) {
    delete docker;
    docker = nullptr;
  }
}

std::string MinecraftInstance::GetWorldId() { return worldId; }

std::string MinecraftInstance::GetConfig() { return config; }

std::string MinecraftInstance::GetWorldStore() { return worldStore; }

std::string MinecraftInstance::GetContainerId() { return containerId; }

void MinecraftInstance::start() {
  docker->startContainer(containerId);
}

void MinecraftInstance::stop() {
  docker->stopContainer(containerId);
}

void MinecraftInstance::restart() {
  docker->restartContainer(containerId);
}

void MinecraftInstance::deleteWorld() {
  docker->removeContainer(containerId);

  // TODO: Delete world files
}

void MinecraftInstance::updateConfig(std::string config) {
  this->config = config;
  // TODO: Implement
}

void MinecraftInstance::onFilesChanged(const QStringList &files) {
  qDebug() << "Files changed: " << files;
  // TODO: Implement
}
