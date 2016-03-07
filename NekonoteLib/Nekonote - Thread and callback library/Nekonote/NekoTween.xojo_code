#tag Class
Class NekoTween
	#tag Method, Flags = &h0
		Sub Constructor(TargetObject as Object, PropName as String)
		  
		  If TargetObject = Nil Then
		    Raise New NilObjectException
		  End If
		  
		  Dim CI    as Introspection.TypeInfo = Introspection.GetType(TargetObject)
		  Dim PIs() as Introspection.PropertyInfo = CI.GetProperties()
		  For Each PI as Introspection.PropertyInfo in PIs
		    If PI.Name = PropName Then
		      //Retain PropertyInfo and TargetObject
		      TargetProp = PropName
		      TargetPropInfo = PI
		      TargetRef = New WeakRef(TargetObject)
		      Exit
		    End If
		  Next
		  
		  If TargetRef = Nil Then
		    Raise New KeyNotFoundException
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EndTween()
		  SetValue Me.EndValue
		  If OnEnd <> Nil Then
		    OnEnd.Execute
		  End If
		  StartTimeMS = 0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetPropName() As String
		  Return TargetProp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetTarget() As Object
		  Return TargetRef.Value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetValue() As Double
		  If TargetPropInfo = Nil or TargetRef.Value = Nil Then
		    Return 0
		  End If
		  
		  Try
		    Return TargetPropInfo.Value(TargetRef.Value)
		  Catch Ex as RuntimeException
		    Return 0
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetValue(Value as Double)
		  If TargetPropInfo = Nil or TargetRef.Value = Nil Then
		    Return
		  End If
		  
		  Try
		    TargetPropInfo.Value(TargetRef.Value) = Value
		  Catch Ex as RuntimeException
		    //Ignore
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartTween(EndValue as Double)
		  
		  Me.StartTimeMS = Microseconds
		  Me.StartValue  = GetValue
		  Me.EndValue    = EndValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartTween(StartValue as Double, EndValue as Double, Optional Duration as Double, Type as Integer = - 1)
		  If Duration > 0 Then
		    Me.DurationMiliSec = Duration
		  End If
		  If Type >= 0 Then
		    Me.TweenType = Type
		  End If
		  
		  SetValue StartValue
		  StartTween(EndValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UpdateValue() As Boolean
		  If Me.StartTimeMS  <= 0 Then
		    Return True //Not started yet
		    //開始前のtweenが終了と見なされて削除されないよう、trueをかえす
		  End If
		  
		  Dim MS as Double = Microseconds
		  Dim R as Double = (MS - Me.StartTimeMS)/(Me.DurationMiliSec * 1000)
		  R = Max(Min(R,1),0)
		  
		  SetValue ValueForRate(Me.StartValue,Me.EndValue,R)
		  If OnUpdate <> Nil Then
		    OnUpdate.Execute
		  End If
		  
		  If R = 1 Then
		    EndTween
		  End If
		  
		  Return R <> 1
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ValueForRate(Value1 as Double, Value2 as Double, R as Double) As Double
		  
		  Select Case TweenType
		  Case kTypeEaseIn
		    Dim RE as Double = R * R
		    Return Value1 * (1 - RE) + Value2 * RE
		  Case kTypeEaseOut
		    Dim RE as Double = 1 - (1-R) * (1-R)
		    Return Value1 * (1 - RE) + Value2 * RE
		  Else
		    Return Value1 * (1 - R) + Value2 * R
		  End Select
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		DurationMiliSec As Double = 300
	#tag EndProperty

	#tag Property, Flags = &h0
		EndValue As Double = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		OnEnd As NekoCallback
	#tag EndProperty

	#tag Property, Flags = &h0
		OnUpdate As NekoCallback
	#tag EndProperty

	#tag Property, Flags = &h21
		Private StartTimeMS As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		StartValue As Double = 0
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TargetProp As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TargetPropInfo As Introspection.PropertyInfo
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TargetRef As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h0
		TweenType As Integer = 0
	#tag EndProperty


	#tag Constant, Name = kTypeEaseIn, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeEaseOut, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTypeNormal, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="DurationMiliSec"
			Group="Behavior"
			InitialValue="300"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EndValue"
			Group="Behavior"
			InitialValue="0"
			Type="Double"
		#tag EndViewProperty
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
			Name="StartValue"
			Group="Behavior"
			InitialValue="0"
			Type="Double"
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
		#tag ViewProperty
			Name="TweenType"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
