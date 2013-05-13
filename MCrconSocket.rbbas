#tag Class
Protected Class MCrconSocket
Inherits TCPSocket
	#tag Event
		Sub Connected()
		  OutStandingRequests = New Dictionary
		  Call Me.SendCommand(Password, MCrconSocket.Type_Password)
		End Sub
	#tag EndEvent

	#tag Event
		Sub DataAvailable()
		  Dim mb As MemoryBlock = Me.ReadAll()
		  Dim len, type, ID As Integer
		  len = mb.Int32Value(0)
		  ID = mb.Int32Value(4)
		  type = mb.Int32Value(8)
		  Dim s As String = mb.CString(12)
		  If Not Response(type, ID, s) Then OutStandingRequests.Remove(ID)
		End Sub
	#tag EndEvent

	#tag Event
		Sub SendComplete(userAborted as Boolean)
		  #pragma Unused userAborted
		End Sub
	#tag EndEvent

	#tag Event
		Function SendProgress(bytesSent as Integer, bytesLeft as Integer) As Boolean
		  #pragma Unused bytesSent
		  #pragma Unused bytesLeft
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Function LookupRequestID(ID As Integer) As String
		  If OutStandingRequests.HasKey(ID) Then
		    Return OutStandingRequests.Value(ID)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function MCPacket(Type As Integer, RequestID As Integer, Payload As String) As MemoryBlock
		  'The MC server expects packets to be structured like this:
		  '
		  '4 bytes: size of packet - 4
		  '4 bytes: any 4 byte value. Responses from the server regarding this packet will have this value.
		  '4 bytes: An integer. Either Type_Command or Type_Password
		  '(variable): An ASCII-encoded string.
		  '2 bytes: Two null bytes.
		  
		  Dim mb As New MemoryBlock(Payload.Len + 4 + 4 + 4 + 3)
		  mb.LittleEndian = True
		  mb.Int32Value(0) = mb.Size - 4
		  mb.Int32Value(4) = RequestID
		  mb.Int32Value(8) = Type
		  mb.CString(12) = Payload + Chr(0) + Chr(0)
		  Return mb
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NextID() As Integer
		  'The ID is any 4-byte value expressed as an Integer. The MC server will use this value
		  'as the ResponseID.
		  LastID = LastID + 1
		  Return LastID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SendCommand(Command As String, Type As Integer = Type_Command) As Integer
		  Dim ID As Integer = NextID
		  Dim mb As MemoryBlock = MCPacket(Type, ID, Command)
		  Me.Write(mb)
		  Me.Flush()
		  OutStandingRequests.Value(ID) = Command
		  Return ID
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Response(Type As Integer, RequestID As Integer, Payload As String) As Boolean
	#tag EndHook


	#tag Note, Name = About this class
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
	#tag EndNote


	#tag Property, Flags = &h21
		Private LastID As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected OutStandingRequests As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Password As String
	#tag EndProperty


	#tag Constant, Name = Type_Command, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Type_Password, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Password"
			Visible=true
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
