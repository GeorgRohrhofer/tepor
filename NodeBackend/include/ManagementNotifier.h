#ifndef MANAGEMENTNOTIFIER_H
#define MANAGEMENTNOTIFIER_H

#include "NetworkManager.h"
#include <QAbstractSocket>
#include <QObject>
#include <QString>

class ManagementNotifier : public QObject {
  Q_OBJECT

public:
  explicit ManagementNotifier(QObject *parent = nullptr);
  ~ManagementNotifier();
  void sendWorldSaved(std::string worldName);

signals:
  void connected();
  void disconnected();
  void registered();

  void serverCreateReceived(std::string worldId, std::string config);
  void serverStartReceived(std::string worldId);
  void serverRestartReceived(std::string worldId);
  void serverStopReceived(std::string worldId);
  void serverDeleteReceived(std::string worldId);
  void updateConfigReceived(std::string worldId, std::string config);

  void worldSyncReceived();
  void errorOccurred(const QString &error);

private slots:

  void onConnected();
  void onDisconnected();
  void onMessageReceived(const QByteArray &data);
  void onErrorOccurred(const QString &error);

private:
  NetworkManager *nm;
  std::string activeId;
};

#endif // MANAGEMENTNOTIFIER_H
