package hunger.server;

import hunger.shared.MsgQueue;
import hunger.shared.Player;
import sys.net.Socket;
import protohx.Message;
import haxe.io.BytesOutput;

/**
 * ...
 * @author John Turner
 */
class PlayerSession {
	public static var nextId = 1;
	public var id: Int;
	public var player: Player;
    public var socket: Socket;
	public var msgQ: MsgQueue;
	
    public function new(socket:Socket) {
        this.socket = socket;
		id = nextId++;
        socket.setFastSend(true);
        socket.output.bigEndian = false;
        socket.input.bigEndian = false;
		msgQ = new MsgQueue();
    }

    public function close():Void {
        socket.close();
    }

    public function writeMsg(msg: Message):Void {
        try{
            var bytes = msgToBytes(msg);
            socket.output.writeUInt16(bytes.length);
            socket.output.write(bytes);
            socket.output.flush();
        }catch(e:Dynamic){
            trace(e);
            #if haxe3
            trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
            #else
            trace(haxe.Stack.toString(haxe.Stack.exceptionStack()));
            #end
        }
    }

    public static function msgToBytes(msg:Message):haxe.io.Bytes {
        var b = new BytesOutput();
        msg.writeTo(b);
        return b.getBytes();
    }

}