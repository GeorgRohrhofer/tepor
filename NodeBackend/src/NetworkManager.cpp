#include "NetworkManager.h"
#include <qlogging.h>
#include <qobject.h>
#include <qsharedpointer.h>
#include <sys/socket.h>

NetworkManager::NetworkManager(QObject *parent) 
  : QObject(parent), socket(nullptr) {
  socket = new QTcpSocket(this);

  connect(socket, &QTcpSocket::connected, this, &NetworkManager::onConnected);
  connect(socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
  connect(socket, &QTcpSocket::readyRead, this, &NetworkManager::onReadyRead);
  connect(socket, &QTcpSocket::errorOccurred, this, &NetworkManager::onError);
}

NetworkManager::~NetworkManager() {
  delete socket;
}

void NetworkManager::connectToServer(const QString &host, quint16 port) {
  if (socket->state() == QAbstractSocket::ConnectedState) {
    qDebug() << "Already connected";
    return;
  }

  qDebug() << "Connecting to " << host << ":" << port;
  socket->connectToHost(host, port);
}

void NetworkManager::sendMessage(const QByteArray &data) {
  if (socket->state() != QAbstractSocket::ConnectedState) {
    qWarning() << "Cannot send - not connected";
    emit errorOccurred("Not connected to server");
    return;
  }

  qint64 written = socket->write(data);
  if (written == -1) {
    qWarning() << "Failed to write data";
    emit errorOccurred("Failed to send message");
    return;
  }

  socket->flush();
  qDebug() << "Sent " << written << " bytes";
}

void NetworkManager::disconnect() {
  if (socket->state() == QAbstractSocket::ConnectedState) {
    socket->disconnectFromHost();
  }
}

void NetworkManager::onConnected() {
  qDebug() << "Connected to server";
  buffer.clear();
  emit connected();
}

void NetworkManager::onDisconnected() {
  qDebug() << "Disconnected from Server";
  buffer.clear();
  emit disconnected();
}

void NetworkManager::onReadyRead() {
  QByteArray data = socket->readAll();
  buffer.append(data);

  emit messageReceived(data);
}

void NetworkManager::onError(QAbstractSocket::SocketError error) {
  QString errorMsg = socket->errorString();
  qWarning() << "Socket error: " << error << " - " << errorMsg;
  emit errorOccurred(errorMsg);
}

void NetworkManager::waitForConnection() {
  socket->waitForConnected();
}

