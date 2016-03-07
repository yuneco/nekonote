#tag Class
Protected Class MainThreadCallbackExecutor
Inherits Timer
	#tag Event
		Sub Action()
		  //スレッドが指定されている（同期モード）場合、止まるまで待つ
		  If Me.CT <> Nil Then
		    Dim T as Double = Microseconds
		    While Me.CT.State <> Thread.Suspended
		      If Microseconds - T > 100 * 1000 Then
		        Raise New SafePropException
		      End If
		    Wend
		  End If
		  
		  //指定のメソッドをコールして結果を取得
		  If CB <> Nil Then
		    CB.Execute
		    ReturnValue = CB.ReturnValue
		  End If
		  
		  Finally
		    Me.Mode = 0
		    Me.CB = Nil
		    
		    //スレッドが指定されている（同期モード）場合、おこす
		    If Me.CT <> Nil Then
		      Try
		        CT.Resume
		      Catch
		      End Try
		    End If
		    
		    //自己参照ロックを解除
		    //非同期モードで呼び出されている場合には、この時点でGCされる可能性有り
		    Me.Locker = Nil
		    
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1001
		Protected Sub Constructor(CB as NekoCallback)
		  Me.CB = CB
		  Me.Mode = 0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub Execute(CB as NekoCallback)
		  //バックグラウンドのスレッドから、渡されたメソッドをメインスレッドで実行します。
		  //実行が依頼されると、すぐに制御は復帰します。
		  //メインスレッド側で実際に処理が実行されるタイミングは不定です。
		  //従って、メソッドの実行結果は取得できません。
		  //（実行結果は渡されたNekoCallbackのReturnValueに格納されますが、格納されるタイミングは不定です）
		  Dim CE as Nekonote.Internal.MainThreadCallbackExecutor = New MainThreadCallbackExecutor(CB)
		  CE.ExecuteInMain(True)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ExecuteInMain(IsAsync as Boolean = True)
		  
		  //同期モードの場合、現在のスレッドを記憶
		  //メインスレッドでの処理完了後におこしてもらう
		  If NOT IsAsync Then
		    Me.CT = App.CurrentThread
		  End If
		  
		  //非同期モード用の自己参照ロック
		  //タイマー処理動作後にActionイベントハンドラ内でリリースされる
		  Me.Locker = Me
		  
		  //この先、どこかのタイミングでメインスレッドからActionイベントが発行される
		  Me.Period = 0
		  Me.Mode = Timer.ModeSingle
		  
		  //同期モードの場合、スレッドの処理を一時停止
		  //Timer.Actionはスレッドの停止を確認後、値の取得を行い、スレッドを再開させる
		  If NOT IsAsync Then
		    Me.CT.Suspend
		  End If
		  
		  Finally
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function ExecuteSync(CB as NekoCallback) As Variant
		  //バックグラウンドのスレッドから、渡されたメソッドをメインスレッドで実行します。
		  //メインスレッドで処理が完了するまで、制御は戻りません。
		  //処理自体に時間が掛かる場合や、メインスレッドがビジーの場合には、呼出しもと
		  //スレッドの処理もその間停止するため、注意して下さい。
		  //戻り値はメソッド処理結果です。（CB.ReturnValueと同一です）
		  Dim CE as Nekonote.Internal.MainThreadCallbackExecutor = New MainThreadCallbackExecutor(CB)
		  CE.ExecuteInMain(False)
		  Return CB.ReturnValue
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected CB As NekoCallback
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CT As Thread
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Locker As Object
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ReturnValue As Variant
	#tag EndProperty


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
			Name="Mode"
			Visible=true
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Off"
				"1 - Single"
				"2 - Multiple"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Period"
			Visible=true
			Group="Behavior"
			InitialValue="1000"
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
