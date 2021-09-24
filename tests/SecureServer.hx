
package;

import hl.Gc;
import yojimbo.Native;
import haxe.io.UInt8Array;

class SecureServer {

    static var privateKeyArrayInt : Array<Int> = [ 0x60, 0x6a, 0xbe, 0x6e, 0xc9, 0x19, 0x10, 0xea, 
        0x9a, 0x65, 0x62, 0xf6, 0x6f, 0x2b, 0x30, 0xe4, 
        0x43, 0x71, 0xd6, 0x2c, 0xd1, 0x99, 0x27, 0x26,
        0x6b, 0x3c, 0x60, 0xf4, 0xb7, 0x15, 0xab, 0xa1 ];
    
    static var privateKey:haxe.io.Bytes = UInt8Array.fromArray(privateKeyArrayInt).view.buffer;

    // should be an int64
    static final  ProtocolId = 0x11223344; //.make(,0x556677);
    static final ClientPort = 30000;
    static final ServerPort = 40000;
    static final MaxClients = 10;

    static function serverMain() : Int {
        return 0;
    }

    static function hostServer( allocator : Allocator) {
        var config = new ClientServerConfig();
        config.protocolId = ProtocolId;

        var address = new Address( "127.0.0.1", ServerPort );
        var time = 100.0;
        
        var adapter = new Adapter();

        var server = new Server( allocator, privateKey, address, config, adapter, time );
        
        server.start( MaxClients );

        final deltaTime = 0.1;
    

        var x :String = server.getAddress().toString();
        trace(x);
        trace( "server address is " + x );

        //srand( (unsigned int) time( NULL ) );
    
        while ( true )
        {
            server.sendPackets();
    
            server.receivePackets();
    
            time += deltaTime;
    
            server.advanceTime( time );
    

            if ( !server.isRunning() )
                break;
    
            Yojimbo.sleep( deltaTime );
        }


        server.stop();
    }
    public static function main()  {
        // SUPER SKETCHY
        Yojimbo.cacheStringType("");

        Yojimbo.initialize();

        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_DEBUG);

        var allocator = Allocator.getDefault();
  
        hostServer(allocator);

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