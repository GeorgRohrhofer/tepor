CREATE TABLE TeporUser (
    id SERIAL PRIMARY KEY
);

CREATE TABLE World (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    hash VARCHAR(255) NOT NULL,
    config TEXT,
    owner_id INTEGER NOT NULL,
    CONSTRAINT fk_world_owner FOREIGN KEY (owner_id) REFERENCES TeporUser(id) ON DELETE CASCADE
);

CREATE TABLE Node (
    id SERIAL PRIMARY KEY,
    availableRAM REAL NOT NULL,
    cpu REAL NOT NULL
);

CREATE TABLE WorldStore (
    world_id INTEGER NOT NULL,
    node_id INTEGER NOT NULL,
    worldHash VARCHAR(255) NOT NULL,
    PRIMARY KEY (world_id, node_id),
    CONSTRAINT fk_worldstore_world FOREIGN KEY (world_id) REFERENCES World(id) ON DELETE CASCADE,
    CONSTRAINT fk_worldstore_node FOREIGN KEY (node_id) REFERENCES Node(id) ON DELETE CASCADE
);

CREATE TABLE Logs (
    id SERIAL PRIMARY KEY,
    node_id INTEGER NOT NULL,
    ramUsage REAL NOT NULL,
    cpuUsage REAL NOT NULL,
    networkUsage REAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_node FOREIGN KEY (node_id) REFERENCES Node(id) ON DELETE CASCADE
);
