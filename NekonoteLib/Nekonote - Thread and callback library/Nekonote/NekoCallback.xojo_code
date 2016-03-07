#tag Class
Class NekoCallback
	#tag Method, Flags = &h0
		Sub Constructor(TargetObject as Object, MethodNme as String, Params() as Variant = Nil, AsWeakRef as Boolean = True)
		  'オブジェクトとメソッド名、パラメータ配列を指定してコールバックオブジェクトを生成します
		  '生成したコールバックオブジェクトはexecuteメソッドで呼び出すことができます。
		  '
		  'コールバックオブジェクトは対象となるオブジェクトを弱参照として保持します。
		  'コールバック時に既に対象オブジェクトが破棄されている場合にはコールバックは失敗します。
		  '引数の配列は通常の参照として保持されます。
		  
		  'note:
		  '指定されたメソッド名のメソッドが複数存在し、かつ引数の数も指定された配列の要素数と等しい場合、
		  'どのメソッドを呼ぶべきかはここでは決定しません。
		  '呼出し時にそれらのメソッドを順次試行し、ParamTypeMissmatchExceptionが発生しなかった場合成功と見なします。
		  
		  //#pragma DisableBackgroundTasks
		  
		  If TargetObject = Nil Then
		    Raise New NilObjectException
		  End If
		  
		  Dim ParamCount as Integer = 0
		  If Params <> Nil Then
		    ParamCount = UBound(Params) + 1
		  End If
		  
		  Dim CI    as Introspection.TypeInfo = Introspection.GetType(TargetObject)
		  Dim PMs() as Introspection.MethodInfo = CI.GetMethods()
		  For Each PM as Introspection.MethodInfo in PMs
		    If PM.Name = MethodNme Then
		      Dim PIs() as Introspection.ParameterInfo = PM.GetParameters
		      If UBound(PIs) + 1 = ParamCount Then
		        
		        CallbackInfo.Insert 0,PM
		        
		      End If
		    End If
		  Next
		  
		  If CallbackInfo = Nil or UBound(CallbackInfo) = -1 Then
		    Raise New KeyNotFoundException
		  End If
		  
		  TargetObjRef = New WeakRef(TargetObject)
		  If NOT AsWeakRef Then
		    //弱参照を用いないオプションが指定された場合、参照を固定的に保持
		    TargetObjHardRef = TargetObject
		  End If
		  CallbackParams  = Params
		  TargetClassInfo = CI
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Create(TargetObject as Object, MethodName as String, ParamArray Params as Variant) As NekoCallback
		  
		  Try
		    If HasMethod(TargetObject,MethodName,Params) Then
		      Return New NekoCallback(TargetObject,MethodName,Params)
		    End If
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub ExecOnBackground(CB as NekoCallback, TM as Nekonote.TaskMng = Nil)
		  //ユーティリティメソッドです
		  //指定のメソッドを簡単にバックグラウンドで実行します
		  
		  If TM = Nil Then
		    TM = TaskMng.Default
		  End If
		  Dim T as Nekonote.TCall = New Nekonote.TCall(CB)
		  TM.AddTask T
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub ExecOnBackground(TargetObject as Object, MethodName as String, TM as Nekonote.TaskMng = Nil, Params() as Variant = Nil, IsWeak as Boolean = False)
		  //ユーティリティメソッドです
		  //指定のメソッドを簡単にバックグラウンドで実行します
		  
		  If TM = Nil Then
		    TM = TaskMng.Default
		  End If
		  Dim CB as NekoCallback = New NekoCallback(TargetObject,MethodName,Params,IsWeak)
		  Dim T as Nekonote.TCall = New Nekonote.TCall(CB)
		  TM.AddTask T
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub ExecOnMainThread(CB as NekoCallback)
		  //ユーティリティメソッドです
		  //指定のメソッドを簡単にメインスレッドで実行します
		  //このユーティリティメソッドは主にバックグラウンドのスレッド中からUIを操作するメソッドを呼ぶために使用します
		  If App.CurrentThread = Nil Then
		    CB.Execute
		  Else
		    Nekonote.Internal.MainThreadCallbackExecutor.Execute(CB)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub ExecOnMainThread(TargetObject as Object, MethodName as String, Params() as Variant = Nil, IsWeak as Boolean = False)
		  //ユーティリティメソッドです
		  //指定のメソッドを簡単にメインスレッドで実行します
		  //このユーティリティメソッドは主にバックグラウンドのスレッド中からUIを操作するメソッドを呼ぶために使用します
		  Dim CB as NekoCallback = New NekoCallback(TargetObject,MethodName,Params,IsWeak)
		  If App.CurrentThread = Nil Then
		    CB.Execute
		  Else
		    Nekonote.Internal.MainThreadCallbackExecutor.Execute(CB)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Execute(ShouldThrowException as Boolean = False, ContextObj as Object = Nil)
		  // コンストラクタで指定したメソッドを実行します。
		  // ShouldThrowException : メソッドの実行時例外を呼出し元にスローします。デフォルトはFalseです。
		  // ContextObj : コンストラクタで指定したのと異なるオブジェクトのメソッドを呼び出す場合に指定します。
		  // 　　　　　　　この場合、指定するオブジェクトのクラスはコンストラクタで指定したものと同一である必要があります。
		  
		  // #pragma DisableBackgroundTasks
		  
		  Dim CBs() as Introspection.MethodInfo = Me.CallbackInfo
		  Dim Base  as Object
		  Dim IsExecuted as Boolean
		  
		  If ContextObj <> Nil Then
		    Base = ContextObj
		  Else
		    Base = TargetObjRef.Value
		    If Base = Nil Then
		      //The Object in TargetObjRef.Value is already destroied
		      Return
		    End If
		  End If
		  
		  For I as Integer = 0 to UBound(CBs)
		    Dim MI as Introspection.MethodInfo = CBs(I)
		    Try
		      Me.ReturnValue = MI.Invoke(Base,CallbackParams)
		      IsExecuted = True
		      Exit
		    Catch CE as IllegalCastException
		      //do nothing and try next
		    End Try
		  Next
		  
		  Exception Ex
		    If ShouldThrowException Then Raise Ex
		  Finally
		    Try
		      Base = Nil
		    Catch TEx as ThreadAccessingUIException
		      //バックグラウンドで実行された場合の問題：
		      //オプジェクトの参照を破棄した結果、デストラクタが走りThreadAccessingUIExceptionが発生する
		      //正しく回避するためには参照を破棄するためのタイマを実行する必要があるが、解放が遅延してしまうのと
		      //問題になる頻度が低いことを考えてエラーを握りつぶす動作とする
		      //＞＞この問題にはバックグラウンドタスクを処理するNekonote.Internal.TaskThread.Runで対処しています
		    End Try
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function HasMethod(TargetObject as Object, MethodNme as String, Params() as Variant = Nil) As Boolean
		  
		  If TargetObject = Nil Then
		    Return False
		  End If
		  
		  Dim ParamCount     as Integer = 0
		  If Params <> Nil Then
		    ParamCount = UBound(Params) + 1
		  End If
		  
		  Dim CI    as Introspection.TypeInfo = Introspection.GetType(TargetObject)
		  Dim PMs() as Introspection.MethodInfo = CI.GetMethods()
		  For Each PM as Introspection.MethodInfo in PMs
		    If PM.Name = MethodNme Then
		      Dim PIs() as Introspection.ParameterInfo = PM.GetParameters
		      If UBound(PIs) + 1 = ParamCount Then
		        
		        Return True
		        
		      End If
		    End If
		  Next
		  
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAlive() As Boolean
		  Return TargetObjRef <> Nil and TargetObjRef.Value <> Nil
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected CallbackInfo() As Introspection.MethodInfo
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected CallbackParams() As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		ReturnValue As Variant
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TargetClassInfo As Introspection.TypeInfo
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TargetObjHardRef As Object
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TargetObjRef As WeakRef
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
