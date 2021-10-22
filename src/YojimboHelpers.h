#ifndef __YOJIMBO_HELPERS_H_
#define __YOJIMBO_HELPERS_H_

#pragma once

#include <yojimbo/yojimbo.h>
#include <hl.h>
#include <queue>
#include "BufferPool.hpp"
void cacheStringType(vstring *str);

vstring *addressToString(const yojimbo::Address *address);
vdynamic *addressToDynamic(const yojimbo::Address *address);
vbyte *HxGetConnectToken(yojimbo::Matcher *matcher, int *oLength);

struct HLMessage : public yojimbo::Message
{
    uint16_t sequence;

    static BufferPool _pool;

    BufferPool::Buffer _buffer;

    HLMessage()
    {
        sequence = 0;
    }

    virtual ~HLMessage()
    {
        Dispose();
    }
    
    void Dispose()
    {
        if (_buffer.state != BufferPool::Buffer::BUFFER_UNINITIALIZED)
        {
            _pool.Return(_buffer);
            _buffer.state = BufferPool::Buffer::BUFFER_UNINITIALIZED;
        }
    }
    const int MAX_PAYLOAD = 1023;
    const int PAYLOAD_LENGTH_BITS = 10;

    bool SetPayload(unsigned char *data, int size)
    {
        //        printf("Setting payload to %d", size);
        Dispose();

        if (size > MAX_PAYLOAD)
        {
            //          printf("Payload is too big\n");
            return false;
        }

        _buffer = _pool.Rent(size);

        memcpy(_buffer.data, data, size);
        //printf("Buffer is rented for %d - status %d\n", size, _buffer.state);
        return true;
    }

    unsigned char *AccessPayload(int *size)
    {
        *size = _buffer.requestedSize;
        return (unsigned char *)_buffer.data;
    }

    virtual bool SerializeInternal(class yojimbo::ReadStream &stream)
    {
        //printf("Serializing Read\n");
        uint32_t size = -1;
        if (stream.SerializeBits(size, PAYLOAD_LENGTH_BITS))
        {
            Dispose();
            //printf("Serializing (Read) %d bytes\n", size);
            _buffer = _pool.Rent(size);
            if (stream.SerializeBytes((unsigned char *)_buffer.data, size))
            {
                return true;
            }
            else
            {
                //printf("BYTES??\n");
            }
        }
        else
        {
            //printf("BITS??\n");
        }
        return false;
    }

    virtual bool SerializeInternal(class yojimbo::WriteStream &stream)
    {
        //printf("Serializing Write %d bytes \n", _buffer.requestedSize);

        if (_buffer.state != BufferPool::Buffer::BUFFER_ALLOCATED)
        {
            return false;
        }
        if (stream.SerializeBits(_buffer.requestedSize, PAYLOAD_LENGTH_BITS))
        {
            if (stream.SerializeBytes((unsigned char *)_buffer.data, _buffer.requestedSize))
            {
                return true;
            }
        }
        return false;
    }

    virtual bool SerializeInternal(class yojimbo::MeasureStream &stream)
    {
        //printf("Serializing measure\n");
        if (_buffer.state != BufferPool::Buffer::BUFFER_ALLOCATED)
        {
            //  printf("Buffer is unallocted\n");
            return false;
        }
        else
        {
            //printf("Buffer measuring %d\n", _buffer.requestedSize);
        }
        if (stream.SerializeBits(_buffer.requestedSize, PAYLOAD_LENGTH_BITS))
        {
            if (stream.SerializeBytes((unsigned char *)_buffer.data, _buffer.requestedSize))
            {

                return true;
            }
            else
            {
                //printf("bytes no measure\n");
            }
        }
        else
        {
            //            printf("Bits no measure\n");
        }
        return false;
    }
};

class HashlinkMessageFactory : public yojimbo::MessageFactory
{
public:
    const static int NUM_TYPES = 1;

    HashlinkMessageFactory(yojimbo::Allocator &allocator) : yojimbo::MessageFactory(allocator, NUM_TYPES)
    {
    }

    yojimbo::Message *CreateMessageInternal(int type)
    {
        yojimbo::Allocator &allocator = GetAllocator();
        yojimbo::Message *message = YOJIMBO_NEW(allocator, HLMessage);
        SetMessageType(message, type);
        return message;
    }

protected:
};

enum HLEventType
{
    HLYOJIMBO_INVALID,
    HLYOJIMBO_CLIENT_CONNECT,
    HLYOJIMBO_CLIENT_DISCONNECT
};

struct HLEvent
{
    HLEvent()
    {
        type = HLYOJIMBO_INVALID;
    }
    HLEvent(HLEventType t, int cid)
    {
        type = t;
        clientID = cid;
    }

    HLEvent(const HLEvent &h)
    {
        type = h.type;
        clientID = h.clientID;
        message = h.message;
    }
    HLEventType type;
    int clientID;
    HLMessage *message;
};

class HashlinkAdapter : public yojimbo::Adapter
{
private:

    yojimbo::Server *_server;
    yojimbo::Client *_client;

    std::queue<HLEvent> _events;

    HLEvent current;
    bool _valid = false;

public:
    HashlinkAdapter()
    {
    }

    virtual ~HashlinkAdapter()
    {
    }

    void BindServer(yojimbo::Server *s ) {
        _server = s;
    }
    void BindClient(yojimbo::Client *c ) {
        _client = c;
    }
    int incomingEventCount()
    {
        return _events.size();
    }

    HLEventType getEventType()
    {
        if (!_valid)
            return HLYOJIMBO_INVALID;

        return current.type;
    }

    int getClientIndex()
    {
        if (!_valid)
            return -1;
        return current.clientID;
    }

    HLMessage *getMessage()
    {
        if (!_valid)
            return nullptr;
        return current.message;
    }

    bool dequeue()
    {
        if (_events.empty())
        {
            _valid = false;
            return false;
        }
        _valid = true;
        current = _events.front();
        _events.pop();
        return true;
    }

    virtual void OnServerClientConnected(int clientIndex)
    {
        _events.push(HLEvent(HLYOJIMBO_CLIENT_CONNECT, clientIndex));
    }

    virtual void OnServerClientDisconnected(int clientIndex)
    {
        _events.push(HLEvent(HLYOJIMBO_CLIENT_DISCONNECT, clientIndex));
    }

    /** 
    Override this callback to process packets sent from client to server over loopback.
    @param clientIndex The client index in range [0,maxClients-1]
    @param packetData The packet data (raw) to be sent to the server.
    @param packetBytes The number of packet bytes in the server.
    @param packetSequence The sequence number of the packet.
    @see Client::ConnectLoopback
    */
    virtual void ClientSendLoopbackPacket(int clientIndex, const uint8_t *packetData, int packetBytes, uint64_t packetSequence)
    {
       printf("Client to server loopback packet %d, %d, %llu\n", clientIndex, packetBytes, packetSequence);
       if (_server != nullptr) {
           _server->ProcessLoopbackPacket( clientIndex, packetData, packetBytes, packetSequence );
       } else {
           printf("Server loopback is null\n");
       }
    }

    /**
        Override this callback to process packets sent from client to server over loopback.
        @param clientIndex The client index in range [0,maxClients-1]
        @param packetData The packet data (raw) to be sent to the server.
        @param packetBytes The number of packet bytes in the server.
        @param packetSequence The sequence number of the packet.
        @see Server::ConnectLoopbackClient
        */

    virtual void ServerSendLoopbackPacket(int clientIndex, const uint8_t *packetData, int packetBytes, uint64_t packetSequence)
    {
        printf("Server to client loopback packet %d, %d, %lld\n", clientIndex, packetBytes, packetSequence);

        if (_client != nullptr) {
            if (clientIndex == 0) {
                _client->ProcessLoopbackPacket( packetData, packetBytes, packetSequence );
            }
        } else {
            printf("Client loopback is null\n");
        }


    }

    yojimbo::MessageFactory *CreateMessageFactory(yojimbo::Allocator &allocator)
    {
        //printf("Creating message factory\n");
        return YOJIMBO_NEW(allocator, HashlinkMessageFactory, allocator);
    }
};

void hlyojimbo_add_channel(yojimbo::ConnectionConfig *connection, yojimbo::ChannelConfig *config);

#endif