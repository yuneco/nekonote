#tag Class
Protected Class Task
	#tag Method, Flags = &h0
		Sub Constructor()
		  TaskInfo = "処理待ち..."
		  Visible = True
		  Open
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Finish()
		  
		  If ErrorCode <> Nekonote.Consts.kTask_NoError Then
		    HasError = True
		  End If
		  
		  If Me.OnFinish <> Nil Then
		    Nekonote.Internal.MainThreadCallbackExecutor.Execute(OnFinish)
		  End If
		  IsFinished = True
		  Nekonote.Debug.AddToLog "Task:" + TaskName,"Finished:ErrCode=" + Str(ErrorCode)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetIcon() As Picture
		  Return New Picture(32,32,32)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetProgress() As Integer
		  Return Progress
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetStates() As String
		  Return TaskInfo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReqCancel()
		  Nekonote.Debug.AddToLog "Task:" + TaskName,"Accept to cancellation request.wait for stop."
		  
		  IsCanceled = True
		  TaskCanceled
		  HasError = True
		  ErrorCode = Nekonote.Consts.kTask_Error_SysCanceled
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReqStop() As Boolean
		  //Taskの一時停止を要求します
		  //Taskが停止要求に応じた場合Trueを返します
		  
		  Dim Stop as Boolean
		  
		  Stop = TaskStopped
		  IF Stop Then
		    Nekonote.Debug.AddToLog "Task:" + TaskName,"Cancellation request is accepted. wait for stop ..."
		  Else
		    Nekonote.Debug.AddToLog "Task:" + TaskName,"Cancellation request is rejected by task."
		  End If
		  
		  Return Stop
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run(PrevResult as Variant) As Variant
		  Nekonote.Debug.AddToLog "Task:" + TaskName,"Run"
		  ResultOfTask = RunTask(PrevResult)
		  Finish
		  Return ResultOfTask
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event RunTask(Param as Variant) As Variant
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TaskCanceled()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TaskStopped() As Boolean
	#tag EndHook


	#tag Property, Flags = &h0
		ErrorCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		HasError As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsCanceled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsFinished As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			ko
		#tag EndNote
		OnFinish As NekoCallback
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Progress As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ResultOfTask As Variant
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TaskInfo As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TaskName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TaskPriority As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Visible As Boolean
	#tag EndProperty


	#tag Constant, Name = kPriority_Important, Type = Integer, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPriority_Normal, Type = Integer, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPriority_NotImportant, Type = Integer, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="ErrorCode"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasError"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsCanceled"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsFinished"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
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
			Name="TaskName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TaskPriority"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
