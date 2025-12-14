package tepor.velocityplugin;

class ServerMessage {
  private Boolean register;
  private String serverName;
  private String ipAddress;
  private int port;
  
  public Boolean getRegister() {
    return register;
  }

  public void setRegister(Boolean register) {
    this.register = register;
  }

  public String getServerName() {
    return serverName;
  }
    
  public void setServerName(String serverName) {
    this.serverName = serverName;
  }
    
  public String getIpAddress() {
    return ipAddress;
  }
    
  public void setIpAddress(String ipAddress) {
    this.ipAddress = ipAddress;
  }

  public int getPort() { 
    return this.port;
  }

  public void setPort(int port) {
    this.port = port;
  }
    
  @Override
  public String toString() {
    return "ServerMessage{serverName='" + serverName + "', ipAddress='" + ipAddress + "'}";
  }
}
