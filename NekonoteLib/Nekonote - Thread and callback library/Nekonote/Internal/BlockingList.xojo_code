#tag Class
Protected Class BlockingList
	#tag Method, Flags = &h0
		Sub Append(o as Object)
		  Push(o)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Clear()
		  _sem.Signal()
		  
		  ReDim Arr(-1)
		  
		  _sem.Release()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As Nekonote.Internal.BlockingList
		  Dim L as Nekonote.Internal.BlockingList = New BlockingList
		  _sem.Signal()
		  
		  For I as Integer = 0 to Arr.Ubound
		    L.Arr.Append(Arr(I))
		  Next
		  
		  _sem.Release()
		  
		  Return L
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CloneAndClear() As Nekonote.Internal.BlockingList
		  Dim L as Nekonote.Internal.BlockingList = New BlockingList
		  _sem.Signal()
		  
		  For I as Integer = 0 to Arr.Ubound
		    L.Arr.Append(Arr(I))
		  Next
		  ReDim Arr(-1)
		  
		  _sem.Release()
		  
		  Return L
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  _sem = New Semaphore
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Length() As Integer
		  Return Arr.Ubound() + 1
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pop() As Object
		  Return Me._getAndRemove(True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Push(o as Object)
		  _sem.Signal()
		  
		  Arr.Append(o)
		  
		  _sem.Release()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Remove(o as Object) As Object
		  Dim ReO as Object = Nil
		  
		  Try
		    _sem.Signal()
		    
		    For I as Integer = 0 to Arr.Ubound
		      If Arr(I) = o Then
		        ReO = Arr(I)
		        Arr.Remove(I)
		        Exit
		      End If
		    Next
		    
		  Finally
		    _sem.Release()
		  End Try
		  
		  Return ReO
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Shift() As object
		  Return Me._getAndRemove(False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unshift(o as Object)
		  _sem.Signal()
		  
		  Arr.Insert(0,o)
		  
		  _sem.Release()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function _getAndRemove(IsPop as Boolean) As Object
		  Dim o as Object
		  
		  _sem.Signal()
		  
		  If UBound(Arr) >= 0 Then
		    If IsPop Then
		      o = Arr.Pop
		    Else
		      o = Arr(0)
		      Arr.Remove(0)
		    End If
		  End If
		  
		  _sem.Release()
		  Return o
		  
		  Exception
		    _sem.Release()
		    
		End Function
	#tag EndMethod


	#tag Note, Name = About
		
		スレッドセーフなリストクラスです
	#tag EndNote


	#tag Property, Flags = &h1
		Protected Arr(-1) As Object
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected _sem As Semaphore
	#tag EndProperty


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
