This class provides an interface to Mojang's rcon protocol for Minecraft servers.
Once connected, MC console commands can be sent to the server using the SendCommand
method:

    Dim sock As New MCrconSocket
    sock.Address = "minecraft.example.com"
    sock.Port = 25566
    sock.Password = "seekrit"
    sock.Connect
    Call sock.SendCommand("/list")

Each command is given a 4-byte RequestID (in this case, an integer). This ID is chosen
by the client rather than the MC server. The server will use this ID to mark response
packets which correspond to a specific Request's ID. The SendCommand method will return
the ID used for the command.

When a response is received from the server, the Response event is Raised. The OutStandingRequests
dictionary stores each sent command under it's ID. Return True from the Response event if the
entry in OutStandingRequests should NOT be removed. You can lookup the original command for a 
requestID by calling LookupRequestID.