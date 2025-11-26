#ifndef MINECRAFTINSTANCE_H
#define MINECRAFTINSTANCE_H

#include <QObject>
#include <QString>
#include <string>
#include <dockerlib.h>

class MinecraftInstance : public QObject {
  Q_OBJECT
public:
  MinecraftInstance(std::string worldId, std::string config,
                    std::string worldStore);
  ~MinecraftInstance();

signals:
  void wordSaved();

public:
  std::string GetWorldId();
  std::string GetConfig();
  std::string GetWorldStore();
  std::string GetContainerId();

  void start();
  void stop();
  void restart();
  void deleteWorld();
  void updateConfig(std::string config);

private slots:
  void onFilesChanged(const QStringList &files);

private:
  static Docker *docker;
  static int instanceCount;

  std::string worldId;
  std::string config;
  std::string worldStore;
  std::string containerId;
};

#endif // MINECRAFTINSTANCE_H
