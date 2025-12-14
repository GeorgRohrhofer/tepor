#ifndef MANAGEMENTNOTIFIER_H
#define MANAGEMENTNOTIFIER_H

#include "DatabaseManager.h"
#include "NetworkManager.h"

#include <QAbstractSocket>
#include <QObject>
#include <QString>
#include <QUuid>

class ManagementNotifier : public QObject {
  Q_OBJECT

public:
  explicit ManagementNotifier(QObject *parent = nullptr,
                              QString host = "localhost", quint16 port = 8000,
                              DatabaseManager *db = nullptr);
  ~ManagementNotifier();
  void sendWorldSaved(std::string worldName, std::string hash);
  void sendRegister(QUuid uuid);

signals:
  void connected();
  void disconnected();
  void registered(std::string activeId);

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
  DatabaseManager *db;
};

#endif // MANAGEMENTNOTIFIER_H
