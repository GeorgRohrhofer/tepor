#ifndef DOCKERLIB_H
#define DOCKERLIB_H
#include <string>
#include <vector>
#include <map>
#include <memory>

class Docker {
private:
  class Impl;
  std::unique_ptr<Impl> pImpl;

public:
  Docker(const std::string& socket = "/var/run/docker.sock");
  ~Docker();

  Docker(const Docker&) = delete;
  Docker& operator=(const Docker&) = delete;

  Docker(Docker&&) noexcept;
  Docker& operator=(Docker&&) noexcept;

  std::string startContainer(
    const std::string& image, 
    const std::string& containerName = "",
    const std::vector<std::string>& env = {},
    const std::map<std::string, std::string>& portBindings = {}
  );

  void pullImage(std::string& image);
  void stopContainer(const std::string& containerIdOrName, int timeout = 10);
  void removeContainer(const std::string& containerIdOrName, bool force = false);
  std::string getContainerStatus(const std::string& containerIdOrName);
  std::vector<std::string> listContainers(bool all = false);
};

#endif
