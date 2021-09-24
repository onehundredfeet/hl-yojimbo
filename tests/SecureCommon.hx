package;

import yojimbo.Native;

final  ProtocolId = 0x11223344; //.make(,0x556677);
final ClientPort = 30000;
final ServerPort = 40000;


/*
ChannelConfig() : type ( CHANNEL_TYPE_RELIABLE_ORDERED )
        {
            disableBlocks = false;
            sentPacketBufferSize = 1024;
            messageSendQueueSize = 1024;
            messageReceiveQueueSize = 1024;
            maxMessagesPerPacket = 256;
            packetBudget = -1;
            maxBlockSize = 256 * 1024;
            blockFragmentSize = 1024;
            messageResendTime = 0.1f;
            blockFragmentResendTime = 0.25f;
        }
*/
function getConfig() : ClientServerConfig {
    var channel = new ChannelConfig();
    channel.type = ChannelType.CHANNEL_TYPE_RELIABLE_ORDERED;
    var config = new ClientServerConfig();
    config.addChannel(channel);
    config.protocolId = SecureCommon.ProtocolId;

    return config;
}