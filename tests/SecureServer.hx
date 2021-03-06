
package;

import haxe.ds.GenericStack.GenericCell;
import hl.Gc;
import yojimbo.Native;
import haxe.io.UInt8Array;
using SecureCommon;

class SecureServer {

    function new() {

    }

    static var privateKeyArrayInt : Array<Int> = [ 0x60, 0x6a, 0xbe, 0x6e, 0xc9, 0x19, 0x10, 0xea, 
        0x9a, 0x65, 0x62, 0xf6, 0x6f, 0x2b, 0x30, 0xe4, 
        0x43, 0x71, 0xd6, 0x2c, 0xd1, 0x99, 0x27, 0x26,
        0x6b, 0x3c, 0x60, 0xf4, 0xb7, 0x15, 0xab, 0xa1 ];
    
    static var privateKey:haxe.io.Bytes = UInt8Array.fromArray(privateKeyArrayInt).view.buffer;

    // should be an int64
    static final MaxClients = 10;

    var clients : Array<Int> = [];


    function frameUpdate(server : Server, adapter : Adapter, time : Float) {
        
    
        server.receivePackets();

        server.advanceTime( time );

        if ( !server.isRunning() )
            return;

        if (adapter.dequeue()) { 
            trace("Remaining " + adapter.incomingEventCount());

            if (adapter.getEventType() == HLEventType.HLYOJIMBO_CLIENT_CONNECT) {
                trace("Client conected " + adapter.getClientIndex());
                clients.push(adapter.getClientIndex());
            } else if (adapter.getEventType() == HLEventType.HLYOJIMBO_CLIENT_DISCONNECT) {
                trace("Client disconected " + adapter.getClientIndex());
                clients.remove(adapter.getClientIndex());
            } else {
                trace("Unknown event " + adapter.getEventType());
            }
        }

        for(c in clients) {
            
            var m : Message = null;

            while ((m = server.receiveMessage(c, 0)) != null) {
                trace("message  " );

                server.releaseMessage(c,m);
            }
        }

    }

    var _server : Server;

    function hostServer( allocator : Allocator) {
        var config = SecureCommon.getConfig();
        var address = new Address( "127.0.0.1", SecureCommon.ServerPort );
        var time = 100.0;
        
        var adapter = new Adapter();

        _server = new Server( allocator, privateKey, address, config, adapter, time );
        
        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_INFO);

        _server.start( MaxClients );

        final deltaTime = 0.1;
        final BROADCAST_PERIOD = 3.;

        var x :String = _server.getAddress().toString();
        trace(x);
        trace( "server address is " + x );
    
        var broadcast = 0.;

        while ( true )
        {
            frameUpdate(_server, adapter, time);

            broadcast += deltaTime;

            if (broadcast > BROADCAST_PERIOD) {
                broadcast = 0.;
                sendBroadcast();
            }
            _server.sendPackets();

            Yojimbo.sleep( deltaTime );
            time += deltaTime;
        }


        _server.stop();
    }

    function sendBroadcast() {
        trace ("Broadcasting");

        for(c in clients) {
            var m = _server.createMessage(c,0);
            _server.sendMessage(c, 0, m);
        }

    }
    public static function main()  {
        // SUPER SKETCHY
        Yojimbo.cacheStringType("");

        Yojimbo.initialize();

        

        var allocator = Allocator.getDefault();
  
        var secureServer = new SecureServer();

        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_INFO);

        secureServer.hostServer(allocator);

        Gc.major();

        Yojimbo.shutdown();
    }
}

/*
#if FALSE

#include "yojimbo.h"
#include <signal.h>
#include <time.h>

#include "shared.h"

using namespace yojimbo;

static volatile int quit = 0;

void interrupt_handler( int  )
{
    quit = 1;
}

int ServerMain()
{
    printf( "started server on port %d (secure)\n", ServerPort );

    double time = 100.0;

    ClientServerConfig config;
    config.protocolId = ProtocolId;

    uint8_t privateKey[KeyBytes] = { 0x60, 0x6a, 0xbe, 0x6e, 0xc9, 0x19, 0x10, 0xea, 
                                     0x9a, 0x65, 0x62, 0xf6, 0x6f, 0x2b, 0x30, 0xe4, 
                                     0x43, 0x71, 0xd6, 0x2c, 0xd1, 0x99, 0x27, 0x26,
                                     0x6b, 0x3c, 0x60, 0xf4, 0xb7, 0x15, 0xab, 0xa1 };

    Server server( GetDefaultAllocator(), privateKey, Address( "127.0.0.1", ServerPort ), config, adapter, time );

    server.Start( MaxClients );

    const double deltaTime = 0.1;

    char addressString[256];
    server.GetAddress().ToString( addressString, sizeof( addressString ) );
    printf( "server address is %s\n", addressString );

    signal( SIGINT, interrupt_handler );    

    while ( !quit )
    {
        server.SendPackets();

        server.ReceivePackets();

        time += deltaTime;

        server.AdvanceTime( time );

        if ( !server.IsRunning() )
            break;

        yojimbo_sleep( deltaTime );
    }

    server.Stop();

    return 0;
}

int main()
{
    printf( "\n" );

    if ( !InitializeYojimbo() )
    {
        printf( "error: failed to initialize Yojimbo!\n" );
        return 1;
    }

    yojimbo_log_level( YOJIMBO_LOG_LEVEL_INFO );

    srand( (unsigned int) time( NULL ) );

    int result = ServerMain();

    ShutdownYojimbo();

    printf( "\n" );

    return result;
}

#end
*/