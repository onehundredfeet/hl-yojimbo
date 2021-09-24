
package;

import hl.Ref;
import haxe.crypto.Base64;
import sys.io.File;
import hl.Gc;
import yojimbo.Native;

class SecureClient {

    static final cert_file = "server.pem";

    public static function main()  {
        Yojimbo.cacheStringType("");

        Yojimbo.initialize();

        var allocator = Allocator.getDefault();
    
        var matcher = new Matcher(  allocator );

        var cert = File.getBytes(cert_file);

        var certStr = File.getContent(cert_file);
        var r = ~/(-----BEGIN CERTIFICATE-----)|(-----END CERTIFICATE-----)|[\r\n]/g;
        var cleanCertStr = r.replace(certStr, "");

        trace(cleanCertStr);

        var certBytes = Base64.decode(cleanCertStr);

//        .replace("-----BEGIN PUBLIC KEY-----", "")
  //      .replaceAll(System.lineSeparator(), "")
    //    .replace("-----END PUBLIC KEY-----", "");
  
      //byte[] encoded = Base64.decodeBase64(publicKeyPEM);


        if (certBytes == null) {
            trace( "error: failed to loading file " + cert_file );
            return ;
        }
        if ( !matcher.initialize(certBytes, certBytes.length) )
        {
            trace( "error: failed to initialize matcher" );
            return ;
        }
    
        trace( "requesting match from https://localhost:443" );

        var clientId =  (Sys.args().length > 0) ? Std.parseInt(Sys.args()[0]) : 12345;

        matcher.requestMatch( "localhost", 443, SecureCommon.ProtocolId, clientId, false );
    
        if ( matcher.getMatchStatus() == MatchStatus.MATCH_FAILED )
        {
            trace( "\nRequest match failed. Is the matcher running?\n" );
            return ;
        } else {
            trace ("Match status " + matcher.getMatchStatus());
        }

        var ctlen = -1;
        var connectToken = matcher.getConnectToken( ctlen );
        trace ("Got connection token " + ctlen);

        var hbytes = connectToken.toBytes(ctlen );


        trace ("Got connection token " + hbytes);
        trace ("Got connection token length " + ctlen);

        final time = 100.0;
    
        var config = SecureCommon.getConfig();


        var adapter = new Adapter();

        var address = new Address("0.0.0.0", SecureCommon.ClientPort);

        var client = new Client(allocator, address, config, adapter, time);

        var serverAddress = new Address( "127.0.0.1", SecureCommon.ServerPort );
        
        trace ("Connecting to (doesn't matter - secure connections get it from the connect token) " + serverAddress.toString());

        client.connect( clientId, connectToken );

        trace ("Connected? to  ");
        if ( client.isDisconnected() )
            return;

        var clientAddress = client.getAddress().toString();

        trace("Client address is " + clientAddress);
        
        final deltaTime = 0.1;
        

        while ( true )
        {
            client.sendPackets();
    
            client.receivePackets();
    
            if ( client.isDisconnected() ) {
                trace ("Disconnected post loop");
                break;
            }
            
            time += deltaTime;
    
            client.advanceTime( time );
    
            if ( client.hasConnectionFailed() )
                break;
    
            Yojimbo.sleep( deltaTime );    

        }
    
        trace ("Disconnecting");
        client.disconnect();
        trace ("Shutting down");

        Yojimbo.shutdown();
        

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