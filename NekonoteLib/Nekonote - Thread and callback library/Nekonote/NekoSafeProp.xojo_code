#tag Class
Class NekoSafeProp
Inherits Timer
	#tag Event
		Sub Action()
		  Sem.Signal
		  //呼出しもとスレッドが停止していない場合、停止するまで待つ
		  Dim T as Double = Microseconds
		  While Me.CT.State <> Thread.Suspended
		    If Microseconds - T > 100 * 1000 Then
		      Raise New SafePropException
		    End If
		  Wend
		  
		  //値の取得またはセット
		  If Me.ActionType = kActionTypeGet Then
		    Me.Buff = Me.PropInfo.Value(TargetObjRef.Value)
		  ElseIf Me.ActionType = kActionTypeSet Then
		    Me.PropInfo.Value(TargetObjRef.Value) = Me.Buff
		  End If
		  
		  Finally
		    
		    ActionType = 0
		    //スレッドを再開
		    Me.CT.Resume
		    
		    Sem.Release
		    
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor(TargetObject as Object, PropName as String)
		  
		  If TargetObject = Nil Then
		    Raise New NilObjectException
		  End If
		  
		  Dim CI    as Introspection.TypeInfo = Introspection.GetType(TargetObject)
		  Dim Ps() as Introspection.PropertyInfo = CI.GetProperties()
		  For Each P as Introspection.PropertyInfo in Ps
		    If P.Name = PropName Then
		      Me.PropInfo = P
		    End If
		  Next
		  
		  If Me.PropInfo = Nil Then
		    Raise New KeyNotFoundException
		  End If
		  
		  TargetObjRef = New WeakRef(TargetObject)
		  
		  Me.Mode = 0
		  Me.Sem = New Semaphore
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetValue() As Variant
		  Sem.Signal
		  While Me.ActionType <> 0
		  Wend
		  
		  //呼出し元スレッドを記憶
		  Me.CT = App.CurrentThread
		  Me.ActionType = kActionTypeGet
		  Me.Period = 0
		  Me.Mode = Timer.ModeSingle
		  
		  //排他を解除。以後、どこかのタイミングでTimer.Actionがメインスレッドから実行される
		  Sem.Release
		  
		  //スレッドの処理を一時停止
		  //Timer.Actionはスレッドの停止を確認後、値の取得を行い、スレッドを再開させる
		  Me.CT.Suspend
		  
		  Sem.Signal
		  //値をバッファから取得
		  Dim V as Variant = Me.Buff
		  Sem.Release
		  
		  Return V
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetValue(V as Variant)
		  Sem.Signal
		  
		  Me.CT = App.CurrentThread
		  Me.Buff = V
		  Me.ActionType = kActionTypeSet
		  Me.Period = 0
		  Me.Mode = Timer.ModeSingle
		  
		  //排他を解除。以後、どこかのタイミングでTimer.Actionがメインスレッドから実行される
		  Sem.Release
		  
		  //スレッドの処理を一時停止
		  //Timer.Actionはスレッドの停止を確認後、値のセットを行い、スレッドを再開させる
		  Me.CT.Suspend
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private ActionType As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Buff As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CT As Thread
	#tag EndProperty

	#tag Property, Flags = &h21
		Private PropInfo As Introspection.PropertyInfo
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Sem As Semaphore
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TargetObjRef As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TimeoutMilisec As Integer = 2500
	#tag EndProperty


	#tag Constant, Name = kActionTypeGet, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kActionTypeSet, Type = Double, Dynamic = False, Default = \"2", Scope = Private
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
