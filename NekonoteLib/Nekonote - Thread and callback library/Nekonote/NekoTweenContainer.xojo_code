#tag Class
Class NekoTweenContainer
Inherits Timer
	#tag Event
		Sub Action()
		  Dim HasNext as Boolean = Update
		  If StopAfterFinishAll and NOT HasNext Then
		    Stop
		  End If
		  
		  If OnUpdate <> Nil Then
		    OnUpdate.Execute
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Add(Tw as NekoTween)
		  TwDic.Value(Tw) = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Period as Integer = 50)
		  TwDic = New Dictionary
		  Me.Mode = 0
		  Me.Period = Period
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As Integer
		  Return TwDic.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Default() As NekoTweenContainer
		  If DefaultContainer = Nil Then
		    DefaultContainer = New NekoTweenContainer
		    DefaultContainer.RemovedFinished = True
		    DefaultContainer.Period = 20
		  End If
		  
		  Return DefaultContainer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(Tw as NekoTween)
		  If TwDic.HasKey(Tw) Then
		    TwDic.Remove(TW)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetAllDuration(Value as Integer)
		  Dim Vs() as Variant = TwDic.Keys
		  
		  For each V as Variant in Vs
		    Dim Tw as NekoTween = NekoTween(V.ObjectValue)
		    If Tw <> Nil Then
		      Tw.DurationMiliSec = Value
		    End If
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetAllTweenType(Value as Integer)
		  Dim Vs() as Variant = TwDic.Keys
		  
		  For each V as Variant in Vs
		    Dim Tw as NekoTween = NekoTween(V.ObjectValue)
		    If Tw <> Nil Then
		      Tw.TweenType = Value
		    End If
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Start(Interval as Integer = 0)
		  If Me.Mode <> 2 Then
		    If Interval > 0 Then
		      Me.Period = Interval
		    End If
		    Me.Mode = 2
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop()
		  Me.Mode = 0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TweenFor(TargetObject as Object, PropName as String) As NekoTween
		  //指定されたオブジェクトの指定されたプロパティを変更するためのNekoTweenオブジェクトを返します
		  //このコンテナ内に存在しない場合、自動的に作成・追加した上で返します。
		  
		  Dim Vs() as Variant = TwDic.Keys
		  Dim Tw as NekoTween
		  
		  For each V as Variant in Vs
		    Tw = NekoTween(V.ObjectValue)
		    If Tw <> Nil Then
		      If Tw.GetTarget = TargetObject and Tw.GetPropName = PropName Then
		        Return Tw
		      End If
		    End If
		  Next
		  
		  //見つからない場合新規生成
		  Tw = New NekoTween(TargetObject,PropName)
		  Tw.DurationMiliSec = Me.DefaultDuration
		  Tw.TweenType = Me.DefaultTweenType
		  Me.Add Tw
		  
		  If AutoStart Then
		    Me.Start //タイマースタートしておく
		  End If
		  Return Tw
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Update() As Boolean
		  Dim Vs() as Variant = TwDic.Keys
		  Dim SomeHasNext as Boolean
		  
		  For each V as Variant in Vs
		    Dim Tw as NekoTween = NekoTween(V.ObjectValue)
		    If Tw <> Nil Then
		      Dim HasNext as Boolean = Tw.UpdateValue
		      SomeHasNext = SomeHasNext or HasNext
		      If Me.RemovedFinished and NOT HasNext Then
		        Remove Tw
		      End If
		    End If
		  Next
		  
		  Return SomeHasNext
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AutoStart As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared DefaultContainer As NekoTweenContainer
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultDuration As Integer = 500
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultTweenType As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		OnUpdate As NekoCallback
	#tag EndProperty

	#tag Property, Flags = &h0
		RemovedFinished As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		StopAfterFinishAll As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TwDic As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AutoStart"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultDuration"
			Group="Behavior"
			InitialValue="500"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultTweenType"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
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
			Name="RemovedFinished"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopAfterFinishAll"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
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
