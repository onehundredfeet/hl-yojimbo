package;

import yojimbo.Native;

final  ProtocolId = 0x11223344; //.make(,0x556677);
final ClientPort = 30000;
final ServerPort = 40000;

function getConfig() : ClientServerConfig {
    var channel = new ChannelConfig();

    var config = new ClientServerConfig();
    config.addChannel(channel);
    config.protocolId = SecureCommon.ProtocolId;

    return config;
}