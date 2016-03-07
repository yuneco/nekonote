#tag Class
Protected Class TaskMng
	#tag Method, Flags = &h0
		Sub AddTask(ATask as Nekonote.Task)
		  
		  If ATask = Nil Then
		    Return
		  End If
		  
		  Init
		  Nekonote.Debug.AddToLog "TaskMng","Task:Name=" + ATask.TaskName + " is posted to Thread:ID=" + Format(Me.ThreadID,"##########")
		  
		  Tasks.AddTask(ATask)
		  If ThreadPool(0).State = 4 Then
		    ThreadPool(0).Run
		  End If
		  
		  If TimerUD.Mode = 0 Then
		    TimerUD.Mode = 2
		  End If
		  
		  Me.Update
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddTasks(Ts() as Nekonote.Task)
		  
		  If UBound(Ts) = -1 Then
		    Return
		  End If
		  
		  Init
		  Nekonote.Debug.AddToLog "TaskMng","Task:Name=" + Ts(0).TaskName + " is posted to Thread:ID=" + Format(Me.ThreadID,"##########")
		  
		  Tasks.AddTasks(Ts)
		  
		  If ThreadPool(0).State = 4 Then
		    ThreadPool(0).Run
		  End If
		  
		  If TimerUD.Mode = 0 Then
		    TimerUD.Mode = 2
		  End If
		  
		  Me.Update
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CancelAllTask()
		  Dim TArr(-1) as Nekonote.Task
		  
		  //先にバックログをクリア
		  Tasks.Clear
		  //バックログが無くなってから現在実行中のタスクを全て中止
		  TArr = GetCrTask
		  For each T as Nekonote.Task in TArr
		    If T <> Nil Then
		      Try
		        T.ReqCancel
		      Catch Exc as RuntimeException
		        Nekonote.Debug.LogError "TaskMng","An error occurred while exec Task:Name=" + T.TaskName + " ,msg=" + Exc.Message
		      End Try
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Close()
		  //処理を終了する場合に呼び出します
		  //タスクが実行中かどうか、外部からの参照があるかどうかに関わらず
		  //任意のタイミングで呼び出しができます。
		  //クローズした後でタスクを追加する事も可能です。
		  
		  CancelAllTask
		  
		  TimerUD.Mode =  0
		  UpdateViewer
		  If Viewer <> Nil Then
		    Viewer.Close
		  End If
		  
		  Nekonote.Debug.AddToLog "TaskMng","Thread:ID=" + Format(Self.ThreadID,"##########") + " is finished all tasks."
		  
		  Finally
		    //ロックオブジェクトを兼ねるTimerUDの参照を切ります
		    //外部からの参照カウント=0の場合、ここでガベージコレクトされます
		    TimerUD = Nil
		    //外部からの参照が残っており、この後でタスクが追加された場合、
		    //AddTaskメソッド内で新たにTimerUDにインスタンスがセットされます
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(ThreadCount as Integer = 1, Priority as Integer = 5)
		  Tasks = New Nekonote.Internal.TaskList
		  Me.ThreadCount = ThreadCount
		  ShouldShowTaskViewer = False
		  Me.Ref = New WeakRef(Me)
		  Me.Priority = Priority
		  
		  InstanseCount = InstanseCount + 1
		  Me.ThreadID = InstanseCount
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Default() As Nekonote.TaskMng
		  If SharedInst = Nil Then
		    SharedInst = New TaskMng()
		    SharedInst.ShouldShowTaskViewer = False
		  End If
		  Return SharedInst
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  CancelAllTask
		  Nekonote.Debug.AddToLog "TaskMng","Thread:ID=" + Str(Self.ThreadID) + " is finished all task and will destroy."
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetCrTask() As Nekonote.Task()
		  //現在実行中のタスクを配列で返します
		  
		  Dim TArr(-1),T as Nekonote.Task
		  
		  For each Th as Nekonote.Internal.TaskThread in ThreadPool
		    T = Th.GetCrTask
		    If T <> Nil Then
		      TArr.Append(T)
		    End If
		  Next
		  
		  Return TArr
		  
		  Exception
		    Return TArr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Init()
		  
		  Dim I as Integer
		  
		  If UBound(ThreadPool) = -1 Then
		    ReDim ThreadPool(ThreadCount - 1)
		    For I = 0 to ThreadCount - 1
		      ThreadPool(I) = New Nekonote.Internal.TaskThread(Tasks)
		      ThreadPool(I).Priority = Me.Priority
		    Next
		  End If
		  
		  If TimerUD = Nil Then
		    //TimerUDは各スレッドの実行状況を監視します
		    //また、外部からの参照が無くなってもガベージコレクトされることを防止します。
		    //必ずインスタンスを生成して下さい
		    TimerUD = New Nekonote.Internal.AutoUpdater(Me)
		    TaskViewerOpenTimeMicsec = Microseconds + 2 * 1000000
		    //TimerUDは初回は2.5秒後に実行され、その時点で未処理タスクが残っている場合に
		    //タスクビューアを表示します。
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsRunning() As Boolean
		  Return Tasks.Length > 0 or RunningThreadCount > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RunningThreadCount() As Integer
		  Dim Count as Integer
		  For each Th as Nekonote.Internal.TaskThread in ThreadPool
		    If Th.State <> 4 Then
		      Count = Count + 1
		    End If
		  Next
		  
		  Return Count
		  Exception
		    Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TaskCount() As Integer
		  Return Tasks.Length
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update()
		  Dim ThCount,ThRunCount as Integer
		  
		  ThCount = UBound(ThreadPool) + 1
		  ThRunCount = RunningThreadCount
		  
		  //処理待ちタスクがあり、かつ停止状態のスレッドがある場合、ひとつを起動する
		  If Tasks.Length > 0 and ThRunCount < ThCount Then
		    For each Th as Nekonote.Internal.TaskThread in ThreadPool
		      If Th.State = kThreadNotRunning Then
		        Nekonote.Debug.AddToLog "TaskMng","Activete an additional thread. total=" + Str(ThRunCount + 1)
		        Th.Run
		        ThRunCount = ThRunCount + 1
		        If ThRunCount > Tasks.Length Then
		          Exit
		        End If
		      End If
		    Next
		  End If
		  
		  If ShouldShowTaskViewer and Microseconds > TaskViewerOpenTimeMicsec Then
		    UpdateViewer
		  End If
		  
		  //動作中のスレッドがない場合、処理終了
		  If ThRunCount = 0 and Tasks.Length = 0 Then
		    Close
		  End If
		  
		  Exception
		    Return
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateViewer()
		  Dim TArr(-1),T as Nekonote.Task
		  TArr = GetCrTask
		  If UBound(TArr) = -1 Then
		    T = Nil
		  Else
		    T = TArr(0)
		  End If
		  
		  Dim TCnt as Integer = Tasks.Length
		  If TCnt = 0 and T = Nil Then
		    If Viewer <> Nil Then
		      Nekonote.Debug.AddToLog "TaskMng","Close task viewer for Thread:ID=" + Format(Self.ThreadID,"##########")
		      Viewer.Close
		      Viewer = Nil
		    End If
		    Return
		  End If
		  If T <> Nil Then
		    If NOT T.Visible Then
		      Return
		    End If
		  End If
		  
		  If Viewer = Nil Then
		    Nekonote.Debug.AddToLog "TaskMng","Open task viewer for Thread:ID=" + Format(Self.ThreadID,"##########")
		    Viewer = New WinTaskViewer
		    Viewer.Left = Screen(0).Width - Viewer.Width - 10
		    Viewer.Top  = Screen(0).Height - Viewer.Height - 10
		    Viewer.Show
		  End If
		  
		  Viewer.Update TArr,TCnt
		  
		  Exception Exc
		    Nekonote.Debug.AddToLog "TaskM","UpdateViewer * " + Exc.Message
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared InstanseCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Priority As Integer = 5
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Ref As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedInst As Nekonote.TaskMng
	#tag EndProperty

	#tag Property, Flags = &h4
		ShouldShowTaskViewer As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Tasks As Nekonote.Internal.TaskList
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TaskViewerOpenTimeMicsec As Double
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ThreadCount As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h0
		ThreadID As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ThreadPool(-1) As Nekonote.Internal.TaskThread
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TimerUD As Nekonote.Internal.AutoUpdater
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Viewer As WinTaskViewer
	#tag EndProperty


	#tag Constant, Name = kThreadNotRunning, Type = Double, Dynamic = False, Default = \"4", Scope = Protected
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
			Name="ShouldShowTaskViewer"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ThreadID"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
