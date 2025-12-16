package tepor.velocityplugin;

import com.velocitypowered.api.event.Subscribe;
import com.velocitypowered.api.event.proxy.ProxyInitializeEvent;
import com.velocitypowered.api.plugin.Plugin;
import com.velocitypowered.api.proxy.ProxyServer;
import org.slf4j.Logger;

import com.google.inject.Inject;

@Plugin(
        id = "velocityplugin",
        name = "VelocityPlugin",
        version = "1.0.0",
        authors = {"Georg Rohrhofer"}
)
public class VelocityPlugin {
    private final ProxyServer server;
    private final Logger logger;

    @Inject
    public VelocityPlugin(ProxyServer server, Logger logger) {
        this.server = server;
        this.logger = logger;
    }

    @Subscribe
    public void onInit(ProxyInitializeEvent event) {
        logger.info("Velocity plugin loaded!");
        new TeporProxy(server).Start();
    }
}

