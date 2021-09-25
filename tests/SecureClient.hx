package;

import hl.Ref;
import haxe.crypto.Base64;
import sys.io.File;
import hl.Gc;
import yojimbo.Native;

class SecureClient {
	function new() {}

	static final cert_file = "server.pem";

	var _allocator:Allocator;

	function getMatch():hl.Bytes {
		var matcher = new Matcher(_allocator);

		var certStr = File.getContent(cert_file);
		var r = ~/(-----BEGIN CERTIFICATE-----)|(-----END CERTIFICATE-----)|[\r\n]/g;
		var cleanCertStr = r.replace(certStr, "");

		trace(cleanCertStr);

		var certBytes = Base64.decode(cleanCertStr);

		if (certBytes == null) {
			throw("error: failed to loading file " + cert_file);
		}
		if (!matcher.initialize(certBytes, certBytes.length)) {
			throw("error: failed to initialize matcher");
		}

		trace("requesting match from https://localhost:443");
		matcher.requestMatch("localhost", 443, SecureCommon.ProtocolId, _clientID, false);
		if (matcher.getMatchStatus() == MatchStatus.MATCH_FAILED) {
			throw("\nRequest match failed. Is the matcher running?\n");
		} else {
			trace("Match status " + matcher.getMatchStatus());
		}

		var ctlen = -1;
		var connectToken = matcher.getConnectToken(ctlen);
		trace("Got connection token " + ctlen);

		var hbytes = connectToken.toBytes(ctlen);
		trace("Got connection token " + hbytes);
		trace("Got connection token length " + ctlen);
		return connectToken;
	}

	var _clientID:Int;

	var _adapter:Adapter;
	var _client:Client;

	function initialize(allocator:Allocator) {
		_allocator = allocator;
		_clientID = (Sys.args().length > 0) ? Std.parseInt(Sys.args()[0]) : 12345;
		_adapter = new Adapter();
	}

    var _time : Float = 10.0;
	function initiateConnection(connectionToken:hl.Bytes) {
		
		var address = new Address("0.0.0.0", SecureCommon.ClientPort);
		var config = SecureCommon.getConfig();

		_client = new Client(_allocator, address, config, _adapter, _time);

		var serverAddress = new Address("127.0.0.1", SecureCommon.ServerPort);

		trace("Connecting to (doesn't matter - secure connections get it from the connect token) " + serverAddress.toString());

		// Initiate connection
		_client.connect(_clientID, connectionToken);

		trace("Connected? to  ");
		if (_client.isDisconnected())
			throw "Something went wrong with the connection";

		var clientAddress = _client.getAddress().toString();

		trace("Client address is " + clientAddress);
	}

	var _connected = false;
	function clientFrame(dt : Float) : Bool{
        _time += dt;

        if (_client == null) {
            throw "What?";
        }
        _client.sendPackets();

        _client.receivePackets();

        if (_client.isDisconnected()) {
            trace("Disconnected post loop");
            return false;
        }

        _client.advanceTime(_time);

        if (_client.hasConnectionFailed()) {
            trace("Connection has failed");
            return false;
        }


        while (_adapter.Dequeue()) {
            switch(_adapter.GetEventType()) {
                case HLEventType.HLYOJIMBO_CLIENT_CONNECT: 
                    trace("Connected!!!!!!!!!!");
                case HLEventType.HLYOJIMBO_CLIENT_DISCONNECT: 
                    trace("Disconnected!");
                default:
            }
        }
        if (_client.isConnected()) {
			if (!_connected) {
				trace("WHEEEEE");
				_connected = true;
			}
            var m : Message = _client.receiveMessage(0);
            while (m != null) {
                trace("Received message M: " + m);
                _client.releaseMessage(m);
                m = _client.receiveMessage(0);
            }   
        }
        return true;
		
	}

    function disconnect() {
		trace("Disconnecting");
		_client.disconnect();
    }
	public static function main() {
		Yojimbo.cacheStringType("");
		Yojimbo.initialize();

       

		var allocator = Allocator.getDefault();
		var c = new SecureClient();
		c.initialize(allocator);
        
        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_INFO);

		final deltaTime = 0.1;

        var ccToken = c.getMatch();

        c.initiateConnection(ccToken);


        while (true) {
            if (!c.clientFrame(deltaTime)) break;

            Yojimbo.sleep(deltaTime);
        }

        c.disconnect();

		trace("Shutting down");

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
