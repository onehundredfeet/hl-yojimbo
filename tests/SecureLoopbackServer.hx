
package;

import hl.Bytes;
import SecureCommon.ClientPort;
import haxe.ds.GenericStack.GenericCell;
import hl.Gc;
import yojimbo.Native;
import haxe.io.UInt8Array;
using SecureCommon;

class SecureLoopbackServer {

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
    var _client : Client;

    function hostServer( allocator : Allocator) {
        var config = SecureCommon.getConfig();
        var address = new Address( "127.0.0.1", SecureCommon.ServerPort );
        var time = 100.0;
        
        var adapter = new Adapter();

        _server = new Server( allocator, privateKey, address, config, adapter, time );
        
        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_INFO);

        _server.start( MaxClients );

        // Started server
        var cid = 0;
        var caddress = new Address( "0.0.0.0", ClientPort );
        _client = new Client(allocator,caddress, config, adapter, time );

        adapter.bindLoopbackClient(_client);
        adapter.bindLoopbackServer(_server);
        
        _client.connectLoopback( 0, cid, MaxClients );
        _server.connectLoopbackClient( 0, cid, null );
    

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
            var m = _server.createMessage(c, 0);
            var b = haxe.io.Bytes.ofString("test");
            m.setPayload(b,b.length);
            _server.sendMessage(c, 0, m);
        }

    }
    public static function main()  {
        // SUPER SKETCHY
        Yojimbo.cacheStringType("");

        Yojimbo.initialize();

        

        var allocator = Allocator.getDefault();
  
        var secureServer = new SecureLoopbackServer();

        Yojimbo.logLevel(LogLevel.YOJIMBO_LOG_LEVEL_INFO);

        secureServer.hostServer(allocator);

        Gc.major();

        Yojimbo.shutdown();
    }
}
