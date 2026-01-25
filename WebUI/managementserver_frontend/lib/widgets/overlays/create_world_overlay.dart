import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateWorldOverlay extends StatefulWidget {
  final VoidCallback onDiscard;
  final void Function(String worldName, String seed, String gamemode, Map<String, dynamic> serverProperties) onCreate;

  const CreateWorldOverlay({
    Key? key,
    required this.onDiscard,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreateWorldOverlay> createState() => _CreateWorldOverlayState();
}

class _CreateWorldOverlayState extends State<CreateWorldOverlay> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _worldNameController = TextEditingController();
  final TextEditingController _seedController = TextEditingController();
  String _selectedGamemode = 'Survival';
  bool _showAdvanced = false;

  final List<String> _gamemodes = ['Creative', 'Adventure', 'Spectator', 'Survival'];
  final List<String> _difficulties = ['peaceful', 'easy', 'normal', 'hard'];
  final List<String> _levelTypes = ['minecraft:normal', 'minecraft:flat', 'minecraft:large_biomes', 'minecraft:amplified', 'minecraft:single_biome_surface'];

  // Server Properties Controllers
  final TextEditingController _motdController = TextEditingController(text: 'A Minecraft Server');
  final TextEditingController _maxPlayersController = TextEditingController(text: '20');
  final TextEditingController _viewDistanceController = TextEditingController(text: '10');
  final TextEditingController _simulationDistanceController = TextEditingController(text: '10');
  final TextEditingController _serverPortController = TextEditingController(text: '25565');
  final TextEditingController _serverIpController = TextEditingController();
  final TextEditingController _rconPortController = TextEditingController(text: '25575');
  final TextEditingController _rconPasswordController = TextEditingController();
  final TextEditingController _queryPortController = TextEditingController(text: '25565');
  final TextEditingController _maxTickTimeController = TextEditingController(text: '60000');
  final TextEditingController _playerIdleTimeoutController = TextEditingController(text: '0');
  final TextEditingController _rateLimitController = TextEditingController(text: '0');
  final TextEditingController _spawnProtectionController = TextEditingController(text: '16');
  final TextEditingController _maxWorldSizeController = TextEditingController(text: '29999984');
  final TextEditingController _opPermissionLevelController = TextEditingController(text: '4');
  final TextEditingController _functionPermissionLevelController = TextEditingController(text: '2');
  final TextEditingController _networkCompressionThresholdController = TextEditingController(text: '256');
  final TextEditingController _entityBroadcastRangePercentageController = TextEditingController(text: '100');
  final TextEditingController _resourcePackController = TextEditingController();
  final TextEditingController _resourcePackSha1Controller = TextEditingController();
  final TextEditingController _resourcePackPromptController = TextEditingController();
  final TextEditingController _generatorSettingsController = TextEditingController(text: '{}');
  final TextEditingController _initialEnabledPacksController = TextEditingController(text: 'vanilla');
  final TextEditingController _initialDisabledPacksController = TextEditingController();

  // Boolean settings
  bool _pvp = true;
  bool _generateStructures = true;
  bool _allowNether = true;
  bool _allowFlight = false;
  bool _enableCommandBlock = false;
  bool _enableQuery = false;
  bool _enableRcon = false;
  bool _enableStatus = true;
  bool _onlineMode = true;
  bool _hardcore = false;
  bool _whiteList = false;
  bool _enforceWhitelist = false;
  bool _forceGamemode = false;
  bool _hideOnlinePlayers = false;
  bool _spawnNpcs = true;
  bool _spawnAnimals = true;
  bool _spawnMonsters = true;
  bool _useNativeTransport = true;
  bool _syncChunkWrites = true;
  bool _preventProxyConnections = false;
  bool _requireResourcePack = false;
  bool _broadcastRconToOps = true;
  bool _broadcastConsoleToOps = true;
  bool _enableJmxMonitoring = false;
  bool _enforceSecureProfile = true;

  String _selectedDifficulty = 'easy';
  String _selectedLevelType = 'minecraft:normal';

  @override
  void dispose() {
    _worldNameController.dispose();
    _seedController.dispose();
    _motdController.dispose();
    _maxPlayersController.dispose();
    _viewDistanceController.dispose();
    _simulationDistanceController.dispose();
    _serverPortController.dispose();
    _serverIpController.dispose();
    _rconPortController.dispose();
    _rconPasswordController.dispose();
    _queryPortController.dispose();
    _maxTickTimeController.dispose();
    _playerIdleTimeoutController.dispose();
    _rateLimitController.dispose();
    _spawnProtectionController.dispose();
    _maxWorldSizeController.dispose();
    _opPermissionLevelController.dispose();
    _functionPermissionLevelController.dispose();
    _networkCompressionThresholdController.dispose();
    _entityBroadcastRangePercentageController.dispose();
    _resourcePackController.dispose();
    _resourcePackSha1Controller.dispose();
    _resourcePackPromptController.dispose();
    _generatorSettingsController.dispose();
    _initialEnabledPacksController.dispose();
    _initialDisabledPacksController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildServerProperties() {
    return {
      'motd': _motdController.text,
      'max-players': int.tryParse(_maxPlayersController.text) ?? 20,
      'view-distance': int.tryParse(_viewDistanceController.text) ?? 10,
      'simulation-distance': int.tryParse(_simulationDistanceController.text) ?? 10,
      'server-port': int.tryParse(_serverPortController.text) ?? 25565,
      'server-ip': _serverIpController.text,
      'rcon.port': int.tryParse(_rconPortController.text) ?? 25575,
      'rcon.password': _rconPasswordController.text,
      'query.port': int.tryParse(_queryPortController.text) ?? 25565,
      'max-tick-time': int.tryParse(_maxTickTimeController.text) ?? 60000,
      'player-idle-timeout': int.tryParse(_playerIdleTimeoutController.text) ?? 0,
      'rate-limit': int.tryParse(_rateLimitController.text) ?? 0,
      'spawn-protection': int.tryParse(_spawnProtectionController.text) ?? 16,
      'max-world-size': int.tryParse(_maxWorldSizeController.text) ?? 29999984,
      'op-permission-level': int.tryParse(_opPermissionLevelController.text) ?? 4,
      'function-permission-level': int.tryParse(_functionPermissionLevelController.text) ?? 2,
      'network-compression-threshold': int.tryParse(_networkCompressionThresholdController.text) ?? 256,
      'entity-broadcast-range-percentage': int.tryParse(_entityBroadcastRangePercentageController.text) ?? 100,
      'resource-pack': _resourcePackController.text,
      'resource-pack-sha1': _resourcePackSha1Controller.text,
      'resource-pack-prompt': _resourcePackPromptController.text,
      'generator-settings': _generatorSettingsController.text,
      'initial-enabled-packs': _initialEnabledPacksController.text,
      'initial-disabled-packs': _initialDisabledPacksController.text,
      'difficulty': _selectedDifficulty,
      'level-type': _selectedLevelType,
      'pvp': _pvp,
      'generate-structures': _generateStructures,
      'allow-nether': _allowNether,
      'allow-flight': _allowFlight,
      'enable-command-block': _enableCommandBlock,
      'enable-query': _enableQuery,
      'enable-rcon': _enableRcon,
      'enable-status': _enableStatus,
      'online-mode': _onlineMode,
      'hardcore': _hardcore,
      'white-list': _whiteList,
      'enforce-whitelist': _enforceWhitelist,
      'force-gamemode': _forceGamemode,
      'hide-online-players': _hideOnlinePlayers,
      'spawn-npcs': _spawnNpcs,
      'spawn-animals': _spawnAnimals,
      'spawn-monsters': _spawnMonsters,
      'use-native-transport': _useNativeTransport,
      'sync-chunk-writes': _syncChunkWrites,
      'prevent-proxy-connections': _preventProxyConnections,
      'require-resource-pack': _requireResourcePack,
      'broadcast-rcon-to-ops': _broadcastRconToOps,
      'broadcast-console-to-ops': _broadcastConsoleToOps,
      'enable-jmx-monitoring': _enableJmxMonitoring,
      'enforce-secure-profile': _enforceSecureProfile,
    };
  }

  Widget _buildNumberField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),

        // Server Settings
        const Text('Server Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField('MOTD', _motdController, hint: 'Message of the Day'),
        Row(
          children: [
            Expanded(child: _buildNumberField('Max Players', _maxPlayersController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Server Port', _serverPortController)),
          ],
        ),
        _buildTextField('Server IP', _serverIpController, hint: 'Leave empty for all interfaces'),

        // World Settings
        const SizedBox(height: 16),
        const Text('World Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedDifficulty,
          items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (v) => setState(() => _selectedDifficulty = v!),
          decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedLevelType,
          items: _levelTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceFirst('minecraft:', '')))).toList(),
          onChanged: (v) => setState(() => _selectedLevelType = v!),
          decoration: const InputDecoration(labelText: 'Level Type', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNumberField('View Distance', _viewDistanceController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Simulation Distance', _simulationDistanceController)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildNumberField('Spawn Protection', _spawnProtectionController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Max World Size', _maxWorldSizeController)),
          ],
        ),
        _buildTextField('Generator Settings', _generatorSettingsController, hint: 'JSON for flat world'),

        // Gameplay Settings
        const SizedBox(height: 16),
        const Text('Gameplay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSwitch('PvP', _pvp, (v) => setState(() => _pvp = v)),
        _buildSwitch('Generate Structures', _generateStructures, (v) => setState(() => _generateStructures = v)),
        _buildSwitch('Allow Nether', _allowNether, (v) => setState(() => _allowNether = v)),
        _buildSwitch('Allow Flight', _allowFlight, (v) => setState(() => _allowFlight = v)),
        _buildSwitch('Hardcore', _hardcore, (v) => setState(() => _hardcore = v)),
        _buildSwitch('Force Gamemode', _forceGamemode, (v) => setState(() => _forceGamemode = v)),
        _buildSwitch('Enable Command Blocks', _enableCommandBlock, (v) => setState(() => _enableCommandBlock = v)),

        // Spawn Settings
        const SizedBox(height: 16),
        const Text('Spawning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSwitch('Spawn NPCs', _spawnNpcs, (v) => setState(() => _spawnNpcs = v)),
        _buildSwitch('Spawn Animals', _spawnAnimals, (v) => setState(() => _spawnAnimals = v)),
        _buildSwitch('Spawn Monsters', _spawnMonsters, (v) => setState(() => _spawnMonsters = v)),

        // Security Settings
        const SizedBox(height: 16),
        const Text('Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSwitch('Online Mode', _onlineMode, (v) => setState(() => _onlineMode = v)),
        _buildSwitch('Whitelist', _whiteList, (v) => setState(() => _whiteList = v)),
        _buildSwitch('Enforce Whitelist', _enforceWhitelist, (v) => setState(() => _enforceWhitelist = v)),
        _buildSwitch('Enforce Secure Profile', _enforceSecureProfile, (v) => setState(() => _enforceSecureProfile = v)),
        _buildSwitch('Prevent Proxy Connections', _preventProxyConnections, (v) => setState(() => _preventProxyConnections = v)),
        _buildSwitch('Hide Online Players', _hideOnlinePlayers, (v) => setState(() => _hideOnlinePlayers = v)),

        // Performance Settings
        const SizedBox(height: 16),
        const Text('Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNumberField('Max Tick Time', _maxTickTimeController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Player Idle Timeout', _playerIdleTimeoutController)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildNumberField('Network Compression', _networkCompressionThresholdController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Rate Limit', _rateLimitController)),
          ],
        ),
        _buildNumberField('Entity Broadcast Range %', _entityBroadcastRangePercentageController),
        _buildSwitch('Use Native Transport', _useNativeTransport, (v) => setState(() => _useNativeTransport = v)),
        _buildSwitch('Sync Chunk Writes', _syncChunkWrites, (v) => setState(() => _syncChunkWrites = v)),

        // RCON & Query
        const SizedBox(height: 16),
        const Text('RCON & Query', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSwitch('Enable RCON', _enableRcon, (v) => setState(() => _enableRcon = v)),
        if (_enableRcon) ...[
          Row(
            children: [
              Expanded(child: _buildNumberField('RCON Port', _rconPortController)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('RCON Password', _rconPasswordController)),
            ],
          ),
        ],
        _buildSwitch('Enable Query', _enableQuery, (v) => setState(() => _enableQuery = v)),
        if (_enableQuery)
          _buildNumberField('Query Port', _queryPortController),
        _buildSwitch('Broadcast RCON to Ops', _broadcastRconToOps, (v) => setState(() => _broadcastRconToOps = v)),
        _buildSwitch('Broadcast Console to Ops', _broadcastConsoleToOps, (v) => setState(() => _broadcastConsoleToOps = v)),

        // Resource Pack
        const SizedBox(height: 16),
        const Text('Resource Pack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField('Resource Pack URL', _resourcePackController),
        _buildTextField('Resource Pack SHA1', _resourcePackSha1Controller),
        _buildTextField('Resource Pack Prompt', _resourcePackPromptController),
        _buildSwitch('Require Resource Pack', _requireResourcePack, (v) => setState(() => _requireResourcePack = v)),

        // Data Packs
        const SizedBox(height: 16),
        const Text('Data Packs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTextField('Initial Enabled Packs', _initialEnabledPacksController),
        _buildTextField('Initial Disabled Packs', _initialDisabledPacksController),

        // Permissions
        const SizedBox(height: 16),
        const Text('Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNumberField('OP Permission Level (1-4)', _opPermissionLevelController)),
            const SizedBox(width: 12),
            Expanded(child: _buildNumberField('Function Permission Level', _functionPermissionLevelController)),
          ],
        ),

        // Miscellaneous
        const SizedBox(height: 16),
        const Text('Miscellaneous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSwitch('Enable Status', _enableStatus, (v) => setState(() => _enableStatus = v)),
        _buildSwitch('Enable JMX Monitoring', _enableJmxMonitoring, (v) => setState(() => _enableJmxMonitoring = v)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _showAdvanced ? 700 : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.grid_on),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Create new World',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // World Name
                TextFormField(
                  controller: _worldNameController,
                  decoration: const InputDecoration(
                    labelText: 'World Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter a world name' : null,
                ),
                const SizedBox(height: 16),

                // Seed
                TextFormField(
                  controller: _seedController,
                  decoration: const InputDecoration(
                    labelText: 'Seed',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Gamemode Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGamemode,
                  items: _gamemodes
                      .map((mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(mode),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGamemode = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Gamemode',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Advanced Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAdvanced = !_showAdvanced;
                    });
                  },
                  icon: Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showAdvanced ? 'Hide Advanced' : 'Advanced'),
                ),

                // Advanced Section
                if (_showAdvanced) _buildAdvancedSection(),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onDiscard,
                      icon: const Icon(Icons.close),
                      label: const Text('Discard'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget.onCreate(
                            _worldNameController.text.trim(),
                            _seedController.text.trim(),
                            _selectedGamemode,
                            _buildServerProperties(),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
