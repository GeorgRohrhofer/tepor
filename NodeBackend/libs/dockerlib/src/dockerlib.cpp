#include "dockerlib.h"

#include <curl/curl.h>
#include <curl/easy.h>
#include <nlohmann/json.hpp>
#include <stdexcept>

using json = nlohmann::json;

class Docker::Impl {
private:
  std::string socket_path;
  CURL *curl;

  static size_t WriteCallback(void *contents, size_t size, size_t nmemb,
                              void *userp) {
    ((std::string *)userp)->append((char *)contents, size * nmemb);
    return size * nmemb;
  }

public:
  Impl(const std::string &socket) : socket_path(socket), curl(nullptr) {
    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (!curl) {
      throw std::runtime_error("Failed to initialize CURL");
    }
  }

  ~Impl() {
    if (curl) {
      curl_easy_cleanup(curl);
    }
    curl_global_cleanup();
  }

  std::string makeRequest(const std::string &endpoint,
                          const std::string &method,
                          const std::string &data = "") {
    std::string response;
    curl_easy_reset(curl);

    curl_easy_setopt(curl, CURLOPT_UNIX_SOCKET_PATH, socket_path.c_str());
    curl_easy_setopt(curl, CURLOPT_URL,
                     ("http://localhost" + endpoint).c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

    struct curl_slist *headers = nullptr;

    if (method == "POST") {
      if (!data.empty()) {
        curl_easy_setopt(curl, CURLOPT_POST, 1L);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, data.length());
        headers = curl_slist_append(headers, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
      } else {
        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
      }
    } else if (method == "GET") {
      curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
    } else if (method == "DELETE") {
      curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
    }

    CURLcode res = curl_easy_perform(curl);

    if (headers) {
      curl_slist_free_all(headers);
    }

    if (method == "DELETE") {
      curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, nullptr);
    }

    if (res != CURLE_OK) {
      throw std::runtime_error("CURL request failed: " +
                               std::string(curl_easy_strerror(res)));
    }

    return response;
  }

  std::string
  createContainer(const std::string &image, const std::string &containerName,
                  const std::vector<std::string> &env,
                  const std::map<std::string, std::string> &portBindings,
                  const std::map<std::string, std::string> &volumeBindings,
                  const bool isFirstTry = true) {
    json createBody = {{"Image", image}, {"Env", env}};

    if (!portBindings.empty()) {
      json exposedPorts = json::object();
      json hostConfig = json::object();
      json portBindingsJson = json::object();

      for (const auto &[containerPort, hostPort] : portBindings) {
        exposedPorts[containerPort] = json::object();
        portBindingsJson[containerPort] =
            json::array({{{"HostPort", hostPort}}});
      }

      // Add volume mounts if provided
      if (!volumeBindings.empty()) {
        json binds = json::array();
        for (const auto &[hostPath, containerPath] : volumeBindings) {
          binds.push_back(hostPath + ":" + containerPath);
        }
        hostConfig["Binds"] = binds;
      }

      createBody["ExposedPorts"] = exposedPorts;
      hostConfig["PortBindings"] = portBindingsJson;
      createBody["HostConfig"] = hostConfig;
    }

    std::string endpoint = "/containers/create";
    if (!containerName.empty()) {
      endpoint += "?name=" + containerName;
    }

    std::string response = makeRequest(endpoint, "POST", createBody.dump());
    json responseJson = json::parse(response);

    if (responseJson.contains("Id")) {
      return responseJson["Id"];
    } else if (isFirstTry) {
      // Image not found.
      // Pull from hub.docker.com
      pullImage(image);
      return createContainer(image, containerName, env, portBindings,
                             volumeBindings, false);
    } else {
      throw std::runtime_error("Error during container creation");
    }
  }

  void startContainer(const std::string &containerIdOrName) {
    std::string containerId = containerIdOrName;
    std::string startEndpoint = "/containers/" + containerId + "/start";
    std::string res = makeRequest(startEndpoint, "POST");
  }

  void pullImage(const std::string image) {
    std::string endpoint = "/images/create?fromImage=" + image;

    std::string response = makeRequest(endpoint, "POST");

    if (response.empty()) {
      throw std::runtime_error("Image could not be pulled");
    }
  }

  void stopContainer(const std::string &containerIdOrName, int timeout) {
    std::string endpoint = "/containers/" + containerIdOrName +
                           "/stop?t=" + std::to_string(timeout);
    makeRequest(endpoint, "POST");
  }

  void restartContainer(const std::string &containerIdOrName, int timeout) {
    std::string endpoint = "/containers/" + containerIdOrName + "/restart";
    makeRequest(endpoint, "POST");
  }

  void removeContainer(const std::string &containerIdOrName, bool force) {
    std::string endpoint = "/containers/" + containerIdOrName +
                           "?force=" + (force ? "true" : "false");
    makeRequest(endpoint, "DELETE");
  }

  std::string getContainerStatus(const std::string &containerIdOrName) {
    std::string endpoint = "/containers/" + containerIdOrName + "/json";
    std::string response = makeRequest(endpoint, "GET");
    json responseJson = json::parse(response);

    if (responseJson.contains("State") &&
        responseJson["State"].contains("Status")) {
      return responseJson["State"]["Status"];
    }
    return "unknown";
  }

  std::vector<std::string> listContainers(bool all) {
    std::string endpoint =
        "/containers/json?all=" + std::string(all ? "true" : "false");
    std::string response = makeRequest(endpoint, "GET");
    json responseJson = json::parse(response);

    std::vector<std::string> containers;
    for (const auto &container : responseJson) {
      if (container.contains("Id")) {
        containers.push_back(container["Id"]);
      }
    }
    return containers;
  }
};

Docker::Docker(const std::string &socket)
    : pImpl(std::make_unique<Impl>(socket)) {}

Docker::~Docker() = default;

Docker::Docker(Docker &&) noexcept = default;
Docker &Docker::operator=(Docker &&) noexcept = default;

std::string Docker::createContainer(
    const std::string &image, const std::string &containerName,
    const std::vector<std::string> &env,
    const std::map<std::string, std::string> &portBindings,
    const std::map<std::string, std::string> &volumeBindings) {
  return pImpl->createContainer(image, containerName, env, portBindings,
                                volumeBindings);
}

void Docker::startContainer(const std::string &containerIdOrName) {
  pImpl->startContainer(containerIdOrName);
}

void Docker::stopContainer(const std::string &containerIdOrName, int timeout) {
  pImpl->stopContainer(containerIdOrName, timeout);
}

void Docker::restartContainer(const std::string &containerIdOrName,
                              int timeout) {
  pImpl->restartContainer(containerIdOrName, timeout);
}

void Docker::removeContainer(const std::string &containerIdOrName, bool force) {
  pImpl->removeContainer(containerIdOrName, force);
}

std::string Docker::getContainerStatus(const std::string &containerIdOrName) {
  return pImpl->getContainerStatus(containerIdOrName);
}

std::vector<std::string> Docker::listContainers(bool all) {
  return pImpl->listContainers(all);
}

void Docker::pullImage(const std::string &image) { pImpl->pullImage(image); }
