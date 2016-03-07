#tag Window
Begin Window WinTaskViewer
   BackColor       =   &cE0E0E000
   Backdrop        =   0
   CloseButton     =   False
   Compatibility   =   ""
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   FullScreenButton=   False
   HasBackColor    =   False
   Height          =   149
   ImplicitInstance=   True
   LiveResize      =   False
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   False
   Title           =   "#MC.Ebako"
   Visible         =   False
   Width           =   364
   Begin Label STTaskName
      AutoDeactivate  =   True
      Bold            =   True
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   15
      HelpTag         =   ""
      Index           =   0
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   False
      LockTop         =   False
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "Task"
      TextAlign       =   0
      TextColor       =   &c00000000
      TextFont        =   ""
      TextSize        =   13.0
      TextUnit        =   0
      Top             =   17
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   225
   End
   Begin ProgressBar PBarTaskProgress
      AutoDeactivate  =   True
      Enabled         =   True
      Height          =   12
      HelpTag         =   ""
      Index           =   0
      InitialParent   =   ""
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Maximum         =   0
      Scope           =   0
      TabIndex        =   "1"
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   64
      Value           =   0
      Visible         =   True
      Width           =   326
   End
   Begin PushButton PBCancel
      AutoDeactivate  =   True
      Bold            =   False
      ButtonStyle     =   "0"
      Cancel          =   False
      Caption         =   "#MC.Stop"
      Default         =   False
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   0
      InitialParent   =   ""
      Italic          =   False
      Left            =   277
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "Osaka"
      TextSize        =   12.0
      TextUnit        =   0
      Top             =   92
      Underline       =   False
      Visible         =   True
      Width           =   69
   End
   Begin Label STTaskInfo
      AutoDeactivate  =   True
      Bold            =   False
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   19
      HelpTag         =   ""
      Index           =   0
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "#MC.waiting_r"
      TextAlign       =   0
      TextColor       =   &c00000000
      TextFont        =   ""
      TextSize        =   11.0
      TextUnit        =   0
      Top             =   36
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   245
   End
   Begin Separator Separator1
      AutoDeactivate  =   True
      Enabled         =   True
      Height          =   4
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   1
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   122
      Visible         =   True
      Width           =   364
   End
   Begin Label STWait
      AutoDeactivate  =   True
      Bold            =   False
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   False
      LockTop         =   False
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   7
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "#MC.WaitToExec_c"
      TextAlign       =   0
      TextColor       =   &c00000000
      TextFont        =   "Osaka"
      TextSize        =   12.0
      TextUnit        =   0
      Top             =   128
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   163
   End
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub CancelTask(Index as Integer)
		  Dim T as Nekonote.Task
		  
		  T = ActiveTasks(Index)
		  If T <> Nil Then
		    T.ReqCancel
		    SetMsg(Index,T.TaskName,"処理の停止を待っています...",0,False)
		  End If
		  
		  Exception
		    Return
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeCount(Count as Integer)
		  Dim CrCount as Integer
		  
		  Const UnitHeight = 120
		  Const BottomHeight = 24
		  
		  Dim STN,STI,Bar,PB as RectControl
		  
		  Self.Height = UnitHeight * Count + BottomHeight
		  
		  CrCount = GetCrCount
		  If CrCount < Count Then
		    //add
		    For I as Integer = CrCount to Count
		      STN = New STTaskName
		      STN.Top = UnitHeight*(I-1) + STTaskName(0).Top
		      STI = New STTaskInfo
		      STI.Top = UnitHeight*(I-1) + STTaskInfo(0).Top
		      Bar = New PBarTaskProgress
		      Bar.Top = UnitHeight*(I-1) + PBarTaskProgress(0).Top
		      PB  = New PBCancel
		      PB.Top = UnitHeight*(I-1) + PBCancel(0).Top
		    Next
		  End If
		  
		  For I as Integer = 0 to Count - 1
		    STTaskName(I).Visible = True
		    STTaskInfo(I).Visible = True
		    PBarTaskProgress(I).Visible = True
		    PBCancel(I).Visible = True
		  Next
		  
		  For I as Integer = Count to CrCount - 1
		    STTaskName(I).Visible = False
		    STTaskInfo(I).Visible = False
		    PBarTaskProgress(I).Visible = False
		    PBCancel(I).Visible = False
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetCrCount() As Integer
		  Dim I as Integer = -1
		  Dim RC as RectControl
		  
		  Try
		    Do
		      I = I + 1
		      RC = STTaskName(I)
		    Loop Until RC = Nil
		  Catch Exc as RuntimeException
		    Return I
		  End Try
		  
		  Return I
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetMsg(Index as Integer, Name as String, Info as String, Progress as Integer, IsCancelEnabled as Boolean)
		  STTaskName(Index).Text = Name
		  STTaskInfo(Index).Text = Info
		  If Progress <= 0 Then
		    PBarTaskProgress(Index).Maximum = 0
		  Else
		    PBarTaskProgress(Index).Maximum = 100
		  End If
		  PBarTaskProgress(Index).Value = Progress
		  
		  PBCancel(Index).Enabled = IsCancelEnabled
		  Exception
		    Return
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTitle(Title as String)
		  Self.Title = Title
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Show()
		  Super.Show
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Update(CrTasks() as Nekonote.Task, WaitingTaskCount as Integer)
		  Dim Count,I as Integer
		  Dim T as Nekonote.Task
		  
		  If UBound(CrTasks) = -1 Then
		    Return
		  End If
		  
		  If Me.GetCrCount <= 0 Then
		    Return
		  End If
		  
		  
		  Count = UBound(CrTasks) + 1
		  ActiveTasks = CrTasks
		  ChangeCount Count
		  For I = 0 to Count - 1
		    T = CrTasks(I)
		    If T.IsCanceled Then
		      SetMsg I,T.TaskName,"タスクの終了を待っています...",T.GetProgress,False
		    Else
		      SetMsg I,T.TaskName,T.GetStates,T.GetProgress,True
		    End If
		  Next
		  
		  
		  If WaitingTaskCount < 1 Then
		    STWait.text = "処理待ち : " + "なし"
		  Else
		    STWait.text = "処理待ち : " + Str(WaitingTaskCount) + "項目"
		  End If
		  
		  Exception
		    Nekonote.Debug.LogError "WinTaskVewer","Error@Update"
		    Close
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private ActiveTasks(-1) As Nekonote.Task
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsShown As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SemaphoreWinLocker As Semaphore
	#tag EndProperty


#tag EndWindowCode

#tag Events PBCancel
	#tag Event
		Sub Action()
		  CancelTask(index)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="BackColor"
		Visible=true
		Group="Appearance"
		InitialValue="&hFFFFFF"
		Type="Color"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Appearance"
		Type="Picture"
		EditorType="Picture"
	#tag EndViewProperty
	#tag ViewProperty
		Name="CloseButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=true
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Frame"
		Visible=true
		Group="Appearance"
		InitialValue="0"
		Type="Integer"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"10 - Drawer Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreenButton"
		Visible=true
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackColor"
		Visible=true
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Position"
		InitialValue="400"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LiveResize"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=true
		Group="Appearance"
		InitialValue="0"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaxHeight"
		Visible=true
		Group="Position"
		InitialValue="32000"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximizeButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaxWidth"
		Visible=true
		Group="Position"
		InitialValue="32000"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Appearance"
		Type="MenuBar"
		EditorType="MenuBar"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinHeight"
		Visible=true
		Group="Position"
		InitialValue="64"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimizeButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinWidth"
		Visible=true
		Group="Position"
		InitialValue="64"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Placement"
		Visible=true
		Group="Position"
		InitialValue="0"
		Type="Integer"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Appearance"
		InitialValue="Untitled"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Position"
		InitialValue="600"
		Type="Integer"
	#tag EndViewProperty
#tag EndViewBehavior
