#tag Class
Protected Class TCall
Inherits Nekonote.Task
	#tag Event
		Function RunTask(Param as Variant) As Variant
		  If Param <> Nil Then Nekonote.Debug.AddToLog(CurrentMethodName,"Ignore Task Param")
		  ParamCB.Execute
		  Return Nil
		End Function
	#tag EndEvent

	#tag Event
		Sub TaskCanceled()
		  ParamCB = Nil
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor(CB as NekoCallback, Name as String = "")
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  
		  Me.ParamCB = CB
		  Me.TaskName = Name
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private ParamCB As NekoCallback
	#tag EndProperty


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
End Class
#tag EndClass
