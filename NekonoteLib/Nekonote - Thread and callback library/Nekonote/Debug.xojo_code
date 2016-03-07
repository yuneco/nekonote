#tag Module
Protected Module Debug
	#tag Method, Flags = &h1
		Protected Sub AddToLog(LogCaller as String, LogMsg as String)
		  System.Log(System.LogLevelInformation,"[" + LogCaller + "]" + LogMsg)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub LogError(LogCaller as String, LogMsg as String)
		  System.Log(System.LogLevelError,"[" + LogCaller + "]" + LogMsg)
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
