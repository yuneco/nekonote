# nekonote
xoxo library for callback and thread util

## LICENCE
Copyright (c) 2016 yuneco.
This software is released under the MIT license.

## Library module "Nekonote" support : 
  * Create & exec callback method
  * Do something on Background
  * Do something on Mainthread (from bg thread)
  * Get/Set UI property from bg thread
  
## Basical usage : 
1. Create & exec callback method

	To create a callback, create a NekoCallback object.    
	`
	Dim cb as New NekoCallback(AnObject,"MethodName")
	`

	You can keep this callback object in property or pass it to others.

	[Note] If a method named "MethodName" is not exists in AnObject,
	this operation raise a KeyNotFoundException.

    To exec callback, just call execute() method.

    `cb.execute()`

    [Note] If the method owner (=AnObject) is not "alive" (already disposed),
    this operation do nothing. To keep the method owner and ensure execution,
    use IsWeak flag. See Advanced usage.

    You can set paramaters to pass to the callback method.

    ```
    Dim Param(-1) as variant
    Param.Append("hi!")
    Param.Append(3)
    Dim cb as New NekoCallback(Me,"showMsgNthTime",Param)
    ```

    This example means 
	`Me.showMsgNthTime("hi!",3)`

	You can get result, of course. Use ReturnValue property.

    ```
    Dim Param(-1) as variant
    Param.Append(2)
    Param.Append(3)
    Dim cb as New NekoCallback(Me,"addNum",Param)
    cb.execute()
    Dim res as Integer = cb.ReturnValue.IntegerValue //=5
	```

2. Do something on Background

	To call a method on bg thread, simply call NekoCallback.ExecOnBackground
    ```
    //pass NekoCallback object
    Dim cb as New NekoCallback(AnObject,"MethodName")
    NekoCallback.ExecOnBackground(cb)
    //or path method owner and methodname directly
    NekoCallback.ExecOnBackground(AnObject,"MethodName")
    ```
	This execute 
    `AnObject.MethodName()`
    on the default background thread.

    [Note] The timing when this callback execute actually is not defined.
    If the default background thread occupied by other tasks, 
    it may takes a long wait before executed.
    To control thread to execute method, see [Advanced usage]  
    
    [Note] Method owner (AnObject) must "alive" when it called actually.
    Next example is failed and nothing will be executed.
    ```
    Sub foo
    Dim AnObject as MyClass = New MyClass()
    NekoCallback.ExecOnBackground(AnObject,"MethodName")
    End Sub
    ```
	In this case, AnObject will be destructed on `End Sub`
    and it my occur before the bg thread run.
    To keep an object until the callback is executed, just set AnObject
    to others property or use IsWeak flag of constructor. See Advanced usage. 
 
3. Do something on Mainthread (from bg thread)
 
    Xojo prohibit threads from calling method that operate UI.
    In Nekonote, you can use NekoCallback.ExecOnMainThread
    ```
    //pass NekoCallback object
    Dim cb as New NekoCallback(AnObject,"MethodName")
    NekoCallback.ExecOnMainThread(cb)
    //or path method owner and methodname directly
    NekoCallback.ExecOnMainThread(AnObject,"MethodName")
    ```
	This execute `AnObject.MethodName()` on the main thread.

    [Note] You have to pay same attention as "Do something on Background".
    
4. Get/Set UI property from bg thread

    NekoSafeProp provide way to access UI property from bg threads.
	```
	Dim safeWindowLeft as NekoSafeProp = new NekoSafeProp(Window1,"Left")
    Dim LeftVal as Integer = safeWindowLeft.GetValue.IntegerValue
    safeWindowLeft.SetValue(LeftValue + 100)
    ```
    [Note] Get/Set method run synchronous and run on the main thread.
    If main thread is occupied by other task, Get/Set method might takes a long time.

## Advanced usage :
1. Keep method owner alive

    NekoCallback callback object refer the method owner in a weak refference.
    If you want to change this behaiver, set IsWeak flag via canstructor param.
	```
	Dim IsWeak as Boolean = False
    Dim cb as New NekoCallback(AnObject,"MethodName",Params,IsWeak)    
  	```

2. Treat RumtimeException

    NekoCallback.execute() ignore all exceptions raised by callback method.
    If you want to change this behaiver, set ShouldThrowException when execute.
    ```
    Dim ThrowErr as Boolean = True
    Try
    	cb.execute(ThrowErr)
    	Catch ... 
    End Try
	```
    
3. Create more background threads

    NekoCallback.ExecOnBackground use default background thread.
    If you want to create your own thread, try following step:
    1) Make Nekocallback object
    ````
    Dim cb as New NekoCallback(AnObject,"MethodName")
	````   
    2) Wrap Nekocallback object by TCall  
    ```
    Dim t as Nekonote.TCall = New Nekonote.TCall(cb)
	```
    
    3) Make new thread and post TCall object
    You can set thread count and its priority.
    ```
    // ThreadCount=3,Priority=5
    Dim tm as New TaskMng(3,5)
    tm.addTask(t)  // this will be executed on thread 1
    tm.addTask(t2) // this will be executed on thread 2
    ```
    You can keep this threads (TaskMng object) and post other TCall repeatedly.

 ## Contact:
 - @yuneco on twitter. 
 - http://nekobooks.com/

