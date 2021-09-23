
package;

import hl.Gc;
import yojimbo.Native;

class SecureClient {
    static final  ProtocolId = 0x11223344; //.make(,0x556677);

    public static function main()  {

        var allocator = Allocator.getDefault();

        var matcher = new Matcher(  allocator );

        if ( !matcher.initialize() )
        {
            trace( "error: failed to initialize matcher" );
            return 1;
        }
    
        trace( "requesting match from https://localhost:8080" );
    
        matcher.requestMatch( ProtocolId, clientId, false );
    
        if ( matcher.getMatchStatus() == MatchStatus.MATCH_FAILED )
        {
            printf( "\nRequest match failed. Is the matcher running? Please run \"premake5 matcher\" before you connect a secure client\n" );
            return 1;
        }


    }
}
/*
#include "yojimbo.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <time.h>
#include <signal.h>
#include "shared.h"

using namespace yojimbo;

static volatile int quit = 0;

void interrupt_handler( int )
{
    quit = 1;
}

int ClientMain( int argc, char * argv[] )
{   
    (void) argc;
    (void) argv;

    printf( "\nconnecting client (secure)\n" );

    uint64_t clientId = 0;
    random_bytes( (uint8_t*) &clientId, 8 );
    printf( "client id is %.16" PRIx64 "\n", clientId );

    Matcher matcher( GetDefaultAllocator() );

    if ( !matcher.Initialize() )
    {
        printf( "error: failed to initialize matcher\n" );
        return 1;
    }

    printf( "requesting match from https://localhost:8080\n" );

    matcher.RequestMatch( ProtocolId, clientId, false );

    if ( matcher.GetMatchStatus() == MATCH_FAILED )
    {
        printf( "\nRequest match failed. Is the matcher running? Please run \"premake5 matcher\" before you connect a secure client\n" );
        return 1;
    }

    uint8_t connectToken[ConnectTokenBytes];
    matcher.GetConnectToken( connectToken );
    printf( "received connect token from matcher\n" );

    double time = 100.0;

    ClientServerConfig config;
    config.protocolId = ProtocolId;

    Client client( GetDefaultAllocator(), Address("0.0.0.0"), config, adapter, time );

    Address serverAddress( "127.0.0.1", ServerPort );

    if ( argc == 2 )
    {
        Address commandLineAddress( argv[1] );
        if ( commandLineAddress.IsValid() )
        {
            if ( commandLineAddress.GetPort() == 0 )
                commandLineAddress.SetPort( ServerPort );
            serverAddress = commandLineAddress;
        }
    }

    client.Connect( clientId, connectToken );

    if ( client.IsDisconnected() )
        return 1;

    char addressString[256];
    client.GetAddress().ToString( addressString, sizeof( addressString ) );
    printf( "client address is %s\n", addressString );

    const double deltaTime = 0.1;

    signal( SIGINT, interrupt_handler );    

    while ( !quit )
    {
        client.SendPackets();

        client.ReceivePackets();

        if ( client.IsDisconnected() )
            break;
     
        time += deltaTime;

        client.AdvanceTime( time );

        if ( client.ConnectionFailed() )
            break;

        yojimbo_sleep( deltaTime );    
    }

    client.Disconnect();
    
    return 0;
}

int main( int argc, char * argv[] )
{
    if ( !InitializeYojimbo() )
    {
        printf( "error: failed to initialize Yojimbo!\n" );
        return 1;
    }

    yojimbo_log_level( YOJIMBO_LOG_LEVEL_INFO );

    srand( (unsigned int) time( NULL ) );

    int result = ClientMain( argc, argv );

    ShutdownYojimbo();

    printf( "\n" );

    return result;
}

*/