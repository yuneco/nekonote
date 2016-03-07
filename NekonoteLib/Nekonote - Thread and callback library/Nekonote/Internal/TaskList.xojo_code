#tag Class
Protected Class TaskList
Inherits BlockingList
	#tag Method, Flags = &h0
		Sub AddTask(ATask as Nekonote.Task)
		  Me._sem.Signal
		  
		  _AddTask_NoSignal(ATask)
		  
		  Me._sem.Release
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddTasks(Ts() as Nekonote.Task)
		  Me._sem.Signal
		  
		  For each ATask as Nekonote.Task in Ts
		    _AddTask_NoSignal(ATask)
		  Next
		  
		  Me._sem.Release
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NextTask() As Nekonote.Task
		  Return Task(Me.Shift)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub _AddTask_NoSignal(ATask as Nekonote.Task)
		  //Taskを待ち行列に追加します
		  //ロックは呼び出し側で掛けて下さい
		  
		  
		  Dim T as Nekonote.Task
		  Dim I,C as Integer
		  Dim IsTaskPosted as Boolean
		  
		  If ATask = Nil Then
		    Return
		  End If
		  
		  C = Me.Arr.UBound + 1
		  
		  For I = C - 1 downTo 0
		    T = Task(Arr(I))
		    If ATask.TaskPriority <= T.TaskPriority Then
		      //同一優先度のタスクの最後尾に配置
		      Arr.Insert I + 1,ATask
		      IsTaskPosted = True
		      Exit
		    End If
		  Next
		  If NOT IsTaskPosted Then
		    Arr.Insert 0,ATask
		  End If
		  
		  
		  
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="2147483648"
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
