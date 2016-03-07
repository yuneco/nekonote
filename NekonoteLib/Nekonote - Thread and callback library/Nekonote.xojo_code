#tag Module
Protected Module Nekonote
	#tag Note, Name = HowToUse
		XOJO Thread utility : Nekonote 
		2016 nekobooks (@yuneco)
		
		
		Library module "Nekonote" support : 
		  * Create & exec callback method
		  * Do something on Background
		  * Do something on Mainthread (from bg thread)
		  * Get/Set UI property from bg thread
		  
		Basical usage : 
		  1 Create & exec callback method
		    To create a callback, create a NekoCallback object.
		    e.g.
		      Dim cb as New NekoCallback(AnObject,"MethodName")
		    You can keep this callback object in property or pass it to others.
		    [Note] If a method named "MethodName" is not exists in AnObject,
		    this operation raise a KeyNotFoundException.
		
		    To exec callback, just call execute() method.
		    e.g.
		      cb.execute()
		    [Note] If the method owner (=AnObject) is not "alive" (already disposed),
		    this operation do nothing. To keep the method owner and ensure execution,
		    use IsWeak flag. See Advanced usage.
		
		    You can set paramaters to pass to the callback method.
		    e.g.
		      Dim Param(-1) as variant
		      Param.Append("hi!")
		      Param.Append(3)
		      Dim cb as New NekoCallback(Me,"showMsgNthTime",Param)
		    This example means 
		      Me.showMsgNthTime("hi!",3)
		
		    You can get result, of course. Use ReturnValue property.
		    e.g.
		      Dim Param(-1) as variant
		      Param.Append(2)
		      Param.Append(3)
		      Dim cb as New NekoCallback(Me,"addNum",Param)
		      cb.execute()
		      Dim res as Integer = cb.ReturnValue.IntegerValue //=5
		
		  2 Do something on Background
		    To call a method on bg thread, simply call NekoCallback.ExecOnBackground
		    e.g. 
		      //pass NekoCallback object
		      Dim cb as New NekoCallback(AnObject,"MethodName")
		      NekoCallback.ExecOnBackground(cb)
		      //or path method owner and methodname directly
		      NekoCallback.ExecOnBackground(AnObject,"MethodName")
		    This execute 
		      AnObject.MethodName()
		    on the default background thread.
		
		    [Note] The timing when this callback execute actually is not defined.
		    If the default background thread occupied by other tasks, 
		    it may takes a long wait before executed.
		    To control thread to execute method, see [Advanced usage]  
		    
		    [Note] Method owner (AnObject) must "alive" when it called actually.
		    Next example is failed and nothing will be executed.
		    e.g.
		      Sub foo
		        Dim AnObject as MyClass = New MyClass()
		        NekoCallback.ExecOnBackground(AnObject,"MethodName")
		      End Sub
		    In this case, AnObject will be destructed on "End Sub"
		    and it my occur before the bg thread run.
		    To keep an object until the callback is executed, just set AnObject
		    to others property or use IsWeak flag of constructor. See Advanced usage. 
		 
		  3 Do something on Mainthread (from bg thread)
		    Xojo prohibit threads from calling method that operate UI.
		    In Nekonote, you can use NekoCallback.ExecOnMainThread
		    e.g.
		      //pass NekoCallback object
		      Dim cb as New NekoCallback(AnObject,"MethodName")
		      NekoCallback.ExecOnMainThread(cb)
		      //or path method owner and methodname directly
		      NekoCallback.ExecOnMainThread(AnObject,"MethodName")
		    This execute
		      AnObject.MethodName()
		    on the main thread.
		
		    [Note] You have to pay same attention as "Do something on Background".
		    
		  4 Get/Set UI property from bg thread
		    NekoSafeProp provide way to access UI property from bg threads.
		    e.g.
		      Dim safeWindowLeft as NekoSafeProp = new NekoSafeProp(Window1,"Left")
		      Dim LeftVal as Integer = safeWindowLeft.GetValue.IntegerValue
		      safeWindowLeft.SetValue(LeftValue + 100)
		    
		    [Note] Get/Set method run synchronous and run on the main thread.
		    If main thread is occupied by other task, Get/Set method might takes a long time.
		
		Advanced usage :
		  1 Keep method owner alive
		    NekoCallback callback object refer the method owner in a weak refference.
		    If you want to change this behaiver, set IsWeak flag via canstructor param.
		      Dim IsWeak as Boolean = False
		      Dim cb as New NekoCallback(AnObject,"MethodName",Params,IsWeak)    
		  
		  2 Treat RumtimeException
		    NekoCallback.execute() ignore all exceptions raised by callback method.
		    If you want to change this behaiver, set ShouldThrowException when execute.
		    e.g.
		      Dim ThrowErr as Boolean = True
		      Try
		        cb.execute(ThrowErr)
		      Catch ... End Try
		
		  3 Create more background threads
		    NekoCallback.ExecOnBackground use default background thread.
		    If you want to create your own thread, try following step:
		    1) Make Nekocallback object
		    e.g.
		      Dim cb as New NekoCallback(AnObject,"MethodName")
		   
		    2) Wrap Nekocallback object by TCall  
		    e.g.
		      Dim t as Nekonote.TCall = New Nekonote.TCall(cb)
		
		    3) Make new thread and post TCall object
		    You can set thread count and its priority.
		    e.g.
		      // ThreadCount=3,Priority=5
		      Dim tm as New TaskMng(3,5)
		      tm.addTask(t)  // this will be executed on thread 1
		      tm.addTask(t2) // this will be executed on thread 2
		    You can keep this threads (TaskMng object) and post other TCall repeatedly.
		
		 
		
	#tag EndNote

	#tag Note, Name = HowToUse(Japanese)
		
		XOJO Thread utility : Nekonote
		2016 nekobooks (@yuneco)
		
		
		"Nekonote" でできること :
		* コールバックメソッドを作って実行する
		* バックグラウンドで任意の処理を実行する
		* （バックグラウンドから）メインスレッドで任意の処理を実行する
		* （バックグラウンドから）UIのプロバティをGet/Setする
		
		基本的な使い方 :
		  1 コールバックメソッドを作って実行する
		    コールバックを作成するにはNekoCallbackを作ります
		    例：
		      Dim cb as New NekoCallback(AnObject,"MethodName")
		    このコールバックはプロパティに保持したり、他のメソッドに渡したりできます。
		    [注意] もし "MethodName" という名前のメソッドがAnObjectにない場合
		    この操作はKeyNotFoundExceptionをスローします。
		
		    コールバックメソッドを実行するには、単にexecute()を呼びます
		    例.
		      cb.execute()
		    [注意] もしメソッドの所有者(=AnObject)が"生きて"いない場合(すでに破棄されている場合)、
		    この操作は何も実行しません。所有者が破棄されることを防いで確実にメソッドが実行
		    されるようにするには、IsWeakフラグを変更します。応用的な使い方を参照してください。
		
		    コールバックにはパラメータを渡せます
		    例.
		      Dim Param(-1) as variant
		      Param.Append("hi!")
		      Param.Append(3)
		      Dim cb as New NekoCallback(Me,"showMsgNthTime",Param)
		    この例をexecuteすると下記のメソッドが実行されます
		      Me.showMsgNthTime("hi!",3)
		
		    もちろん、戻り値も取得できます。ReturnValueプロパティを使います。
		    例.
		      Dim Param(-1) as variant
		      Param.Append(2)
		      Param.Append(3)
		      Dim cb as New NekoCallback(Me,"addNum",Param)
		      cb.execute()
		      Dim res as Integer = cb.ReturnValue.IntegerValue //=5
		
		
		 2 バックグラウンドで任意の処理を実行する
		   スレッドで処理を実行するには、単に NekoCallback.ExecOnBackground を呼び出します
		   例.
		     //作成済みのcallbackを渡す
		     Dim cb as New NekoCallback(AnObject,"MethodName")
		     NekoCallback.ExecOnBackground(cb)
		     //または、メソッドを直接指定
		     NekoCallback.ExecOnBackground(AnObject,"MethodName")
		   これは、下記の処理をバックグラウンドのスレッドで実行します：
		     AnObject.MethodName()
		
		  [注意] メソッドが実際にいつ実行されるかはわかりません。
		  もしバックグラウンドのスレッドが他の処理を実行中なら
		  実際にこのメソッドが呼び出されるまでに長い時間がかかる可能性があります。
		  （ExecOnBackground自体は処理を依頼してすぐに復帰します）
		  スレッドの挙動をコントロールしたい場合、応用的な使い方を参照してください。
		
		  [注意] メソッドの所有者であるAnObjectは実際にメソッドが呼び出される時点で生存している必要があります。
		  例えば、下記の例は呼び出しに失敗し、何も実行されません（エラーも発生しません）
		  例.
		    Sub foo
		      Dim AnObject as New MyClass()
		      NekoCallback.ExecOnBackground(AnObject,"MethodName")
		    End Sub
		  この例ではAnObjectは"End Sub"で破棄されます。
		  この破棄は（大抵は）バックグラウンドのスレッドで処理が実行されるよりも先に起こります。
		  メソッドの実行までAnObjectの破棄を延期するためには、AnObjectを何かのプロパティにセットして保持するか
		  NekoCallbackのオプションを利用します。詳細は応用的な使い方を参照してください。
		
		 3 （バックグラウンドから）メインスレッドで任意の処理を実行する
		  XojoではバックグラウンドのスレッドからUIを操作することを禁止しています。
		  NekonoteではNekoCallback.ExecOnMainThreadを利用してこの制限を安全に回避できます。
		  例.
		    //作成済みのcallbackを渡す
		    Dim cb as New NekoCallback(AnObject,"MethodName")
		    NekoCallback.ExecOnMainThread(cb)
		    //または、メソッドを直接指定
		    NekoCallback.ExecOnMainThread(AnObject,"MethodName")
		  これは、下記をメインスレッドで実行するのと同じです
		    AnObject.MethodName()
		
		  [注意] 留意点は「1 バックグラウンドで任意の処理を実行する」と同様です
		
		 4 （バックグラウンドから）UIのプロバティをGet/Setする
		  NekoSafePropはスレッドからUIのプロパティを参照/設定することができます
		  例.
		    Dim safeWindowLeft as NekoSafeProp = new NekoSafeProp(Window1,"Left")
		    Dim LeftVal as Integer = safeWindowLeft.GetValue.IntegerValue
		    safeWindowLeft.SetValue(LeftValue + 100)
		
		  [注意] Get/Setメソッドはメインスレッドで、かつ同期で実行されます。
		  メインスレッドが他の処理を実行している場合、呼び出し元のスレッドも完了まで待たされます。
		
		応用的な使い方 :
		  1 メソッドの所有者が破棄されないようにする
		  NekoCallbackはメソッドの所有者を弱参照で保持します。
		  この挙動を変えたい場合は、コンストラクタでIsWeakフラグを変更します。
		    Dim IsWeak as Boolean = False   
		    Dim cb as New NekoCallback(AnObject,"MethodName",Params,IsWeak)
		
		  2 例外を扱う
		  NekoCallback.execute()は呼び出したメソッドがスローした例外を全て無視します。
		  この挙動を変えたい場合は、execute呼び出し時にShouldThrowExceptionを変更します。
		  例.
		    Dim ThrowErr as Boolean = True
		    Try
		      cb.execute(ThrowErr)
		    Catch ... End Try
		
		  3 もっとたくさんのスレッドを作る
		  NekoCallback.ExecOnBackgroundはバックグラウンド処理用に一つのスレッドを生成し、共有します。
		  専用のスレッドを作りたい場合、以下のステップを試してください。
		  1) コールバックメソッドを作成
		  例.
		    Dim cb as New NekoCallback(AnObject,"MethodName")
		 
		  2) TCallオブジェクトでラップ
		  例.
		    Dim t as Nekonote.TCall = New Nekonote.TCall(cb)
		
		  3) 新しいスレッド(TaskMng)を作成して、post
		  スレッドの最大数と優先度を指定できます。
		  例.
		    // ThreadCount=3,Priority=5
		    Dim tm as New TaskMng(3,5)
		    tm.addTask(t)  // this will be executed on thread 1
		    tm.addTask(t2) // this will be executed on thread 2
		  このスレッド（TaskMngオブジェクト）はプロパティに保持して、
		  後から任意のタイミングでタスク（TCallオブジェクト）を追加できます。
		  使い捨てる場合はローカル変数で構いません（すべての処理が終わったタイミングで破棄されます）
		
		
		--
		メモ：
		・Nekonoteが扱うスレッドは（残念ながら）すべてxojoの擬似的なスレッドです
		・NekocallbackやTaskがUIに関連したオブジェクトを（間接的にでも）参照している場合、
		　バックグラウンドスレッドでの実行時にUIThreadExceptionが発生することがあります。
		　（場所的にはNekonote.Internal.TaskThread.Runで実行済みのTaskを破棄するときに起こります）
		　これを防止するため、デフォルトではTaskの破棄はすべてメインスレッドで行うようにしていますが、
		　この動作はパフォーマンスに影響する可能性があります。
		　Nekonote.Internal.TaskThread.kFoceDisposeTasksInMainthread定数でこの挙動をOFFにできます。
		　（その場合、UIThreadExceptionが発生してもログ出力のみ行って握りつぶします）
		　破棄されるオブジェクトなのでおそらく問題はないと思いますが、本当に安全かはわかりません。
		
	#tag EndNote


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
