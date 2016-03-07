#tag Class
Protected Class TaskThread
Inherits Thread
	#tag Event
		Sub Run()
		  Dim T as Nekonote.Task
		  Dim V as Variant = Nil
		  
		  Do
		    T = Tasks.NextTask
		    Me.CrTask = T
		    If T = Nil      Then Exit
		    If T.IsCanceled Then Continue
		    
		    Nekonote.Debug.AddToLog "TaskThread",Format(Me.ThreadID,"##########") + " : exec task : " + T.TaskName
		    V = T.Run(V)
		    
		    Me.CrTask = Nil
		    //kFoceDisposeTasksInMainthread=Trueの場合のみ：
		    //このフラグがONの場合、実行したタスクの解放を常にメインスレッドで実行します
		    //タスクがUI要素への参照を保持している場合、このオプションによりThreadAccessUIExceptionを
		    //発生させずに安全に実行済みタスクの解放を行えます。
		    //一方、このオプションを利用すると実行済みタスクの解放が遅延されるため、メモリを圧迫する可能性があります
		    //また、解放は別途Timer処理で実行される為、若干ですがパフォーマンスに影響します
		    #If kFoceDisposeTasksInMainthread Then
		      TasksToBeDisposed.Append T
		      MainThreadCallbackExecutor.Execute(New NekoCallback(Me,"ClearDisposedTasks",Nil,False))
		    #EndIf
		    T = Nil
		    
		    App.YieldToNextThread
		    
		  Loop
		  
		  Nekonote.Debug.AddToLog "TaskThread",Format(Me.ThreadID,"##########") + " : finished"
		  
		  Exception Ex as RuntimeException
		    Nekonote.Debug.LogError "TaskThread","Error on thread running : threadID=" + Str(Me.ThreadID)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub ClearDisposedTasks()
		  ReDim TasksToBeDisposed(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Tasks as Nekonote.Internal.TaskList)
		  Me.Tasks = Tasks
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetCrTask() As Nekonote.Task
		  Return Me.CrTask
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CrTask As Nekonote.Task
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsRunning As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Tasks As Nekonote.Internal.TaskList
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TasksToBeDisposed(-1) As Nekonote.Task
	#tag EndProperty


	#tag Constant, Name = kFoceDisposeTasksInMainthread, Type = Boolean, Dynamic = False, Default = \"True", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
