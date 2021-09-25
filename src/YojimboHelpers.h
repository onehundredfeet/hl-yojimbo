#ifndef __YOJIMBO_HELPERS_H_
#define __YOJIMBO_HELPERS_H_

#pragma once

#include <yojimbo/yojimbo.h>
#include <hl.h>
#include <queue>

void cacheStringType(vstring *str);

vstring *addressToString(const yojimbo::Address *address);
vdynamic *addressToDynamic(const yojimbo::Address *address);
vbyte *HxGetConnectToken(yojimbo::Matcher *matcher, int *oLength);

enum EHashlinkMessage {
    HLMESSAGE_DATA
};

struct HLMessage : public yojimbo::Message
{
    uint16_t sequence;

    HLMessage()
    {
        sequence = 0;
    }

    virtual ~HLMessage() {
        
    }
    template <typename Stream> bool Serialize( Stream & stream )
    {        
        serialize_bits( stream, sequence, 16 );
        return true;
    }

    YOJIMBO_VIRTUAL_SERIALIZE_FUNCTIONS();
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
        yojimbo::Message *message;
        yojimbo::Allocator &allocator = GetAllocator();
        switch (type)
        {
        case HLMESSAGE_DATA:
            message = YOJIMBO_NEW(allocator, HLMessage);
            if (!message)
                return NULL;
            SetMessageType(message, HLMESSAGE_DATA);
            return message;
            default:
                return nullptr;
        }
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

    HLEvent( const HLEvent &h ){
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

    yojimbo::MessageFactory *CreateMessageFactory(yojimbo::Allocator &allocator)
    {
        return YOJIMBO_NEW(allocator, HashlinkMessageFactory, allocator);
    }
};


void hlyojimbo_add_channel( yojimbo::ConnectionConfig *connection, yojimbo::ChannelConfig *config );

#endif