
#CGScrollVertical = 1

DeclareModule CGScrollBar01
  
  ;{ ==Gadget Event Enumerations=================================
;        Name/title: Enumerations
;       Description: Part of custom gadget template
;                  : Enumeration of Custom Gagdet event constants 
;                  : Started at 100 to Avoid Using 0
;                  : as creation events etc can still be recieved
;                  : in main event loop
; ================================================================
;} 
  Enumeration 100
    #CGRaiseSmall
    #CGRaisePage
    #CGLowerSmall
    #CGLowerPage
    #CGChanged
  EndEnumeration
  
  Enumeration #PB_EventType_FirstCustomValue
    #CGScrollChange
    #CGScrollSmallRise
    #CGScrollLargeRise
    #CGScrollLargeFall
    #CGScrollSmallFall
    #CGScrollResize     ;Waiting for next PB version
  EndEnumeration
  
  ;Create the gadget procedure
  Declare New(Gadget.i, x.i,y.i,width.i,height.i,Min.i,Max.i,Page.i,Flags.i = 0)
  
EndDeclareModule

Module CGScrollBar01

  ;The Main Gadget Structure
  Structure MyGadget
    Window_ID.i
    Gadget_ID.i
    BackColour.i
    Enabled.i
    Entered.i
    Width.i
    Height.i
    Minimum.i
    Maximum.i
    Page.i
    Vertical.i 
    Value.d
    Ratio.d             ;Number of pixels per single value of the scrollbar
    Slidercentre.i      ;Pixel Position of current slider centre
  EndStructure
  Global Dim MyGadgetArray.MyGadget(0) 
  Global Currentgadget.i,MouseMoveSelect.i,RepeatAction.i,ActionToRepeat.i
 
  Procedure.i GreyColour(Colour.i)
    
    Define NChrome.i,RetColour.i
    
    NChrome = Round(Red(Colour) * 0.56 + Green(Colour) * 0.33 + Blue(Colour) * 0.11, 0)
    RetColour = RGBA(NChrome,NChrome,NChrome,255)
    ProcedureReturn RetColour

  EndProcedure
   
  Procedure SetCurrentGadgetID(Gadget.i)
  ;{ ==Procedure Header Comment==============================
;        Name/title: GetgadgetID
;       Description: Part of custom gadget template
;                  : Procedure to return the MyGadgetArray() element number 
;                  : for the gadget on which the event occurred
; 
; ====================================================
;}     
    Define iLoop.i
    
    ;If Currentgadget <> Gadget
    
      For iLoop = 0 To ArraySize(MyGadgetArray()) -1

        If Gadget = MyGadgetArray(iLoop)\Gadget_ID

          CurrentGadget = iLoop
        Break
        EndIf
      
      Next iLoop 

    ;EndIf
  
  EndProcedure
  
  Procedure   DrawLeft()
  
    Define Height.i,Width.i
  
    StartVectorDrawing(CanvasVectorOutput(MyGadgetArray(Currentgadget)\Gadget_ID))
  
    If MyGadgetArray(Currentgadget)\Entered = #False
      VectorSourceColor(GreyColour(RGBA(255,0,0,255)))
    Else
      VectorSourceColor(RGBA(255,0,0,255))
    EndIf

    If MyGadgetArray(Currentgadget)\Vertical = #True
    
      Height = VectorOutputWidth()
      Width = VectorOutputHeight()
      RotateCoordinates((Height/2),(Height/2),90)
    
    Else 
    
      Height = VectorOutputHeight()
      Width = VectorOutputWidth()
    
    EndIf     
  
    ;MainButton
    AddPathCircle(Height/2,Height/2,Height/2)
    FillPath()
      
    ;Arrow
    If MyGadgetArray(Currentgadget)\Entered = #False
      VectorSourceColor(GreyColour(RGBA(255,255,255,255)))
    Else
      VectorSourceColor(RGBA(255,255,255,255))
    EndIf   

    MovePathCursor(Height * 0.7, Height * 0.2)
    AddPathLine(Height * 0.1, Height * 0.5)
    AddPathLine(Height * 0.7, Height * 0.8)
    ClosePath()
    FillPath()
      
    ;Start Of Track;
    If MyGadgetArray(Currentgadget)\Entered = #False
      VectorSourceColor(GreyColour(RGBA(255,0,0,255)))
    Else
      VectorSourceColor(RGBA(255,0,0,255))
    EndIf
    AddPathCircle(Height * 1.5,Height * 0.5,Height * 0.4,90,270)
    StrokePath(Height /10)
  StopVectorDrawing()
  
EndProcedure 

  Procedure   DrawTrack()
  
    Define Height.i,Width.i

    StartVectorDrawing(CanvasVectorOutput(MyGadgetArray(Currentgadget)\Gadget_ID))
  
    If MyGadgetArray(Currentgadget)\Vertical = #True
    
      Height = VectorOutputWidth()
      Width = VectorOutputHeight()
      RotateCoordinates((Height/2),(Height/2),90)
   
    Else 
    
      Height = VectorOutputHeight()
      Width = VectorOutputWidth()
    
    EndIf   
    
    If MyGadgetArray(Currentgadget)\Entered = #False
      VectorSourceColor(GreyColour(RGBA(255,0,0,255)))
    Else
      VectorSourceColor(RGBA(255,0,0,255))
    EndIf   
    MovePathCursor(Height * 1.5 ,Height * 0.9)
    AddPathLine(Width - (Height * 1.5),Height * 0.9)
    MovePathCursor(Height * 1.5,Height * 0.1)
    AddPathLine(Width -(Height * 1.5),Height * 0.1)     
    StrokePath(Height /10)
    StopVectorDrawing()

  EndProcedure

  Procedure   DrawRight()
    
    Define Height.i,Width.i    
    Define Offset.i
   
    StartVectorDrawing(CanvasVectorOutput(MyGadgetArray(Currentgadget)\Gadget_ID))
      If MyGadgetArray(Currentgadget)\Entered = #False
        VectorSourceColor(GreyColour(RGBA(255,0,0,255)))
      Else
        VectorSourceColor(RGBA(255,0,0,255))
      EndIf   
     
      If MyGadgetArray(Currentgadget)\Vertical = #True
    
        Height = VectorOutputWidth()
        Width = VectorOutputHeight()
        RotateCoordinates((Height/2),(Height/2),90)
     
      Else 
    
        Height = VectorOutputHeight()
        Width = VectorOutputWidth()
    
      EndIf     
  
      Offset = Width - Height * 1.5
        
      ;MainButton
      AddPathCircle(Offset + Height,Height/2,Height/2)
      FillPath()
      
      ;Arrow
      If MyGadgetArray(Currentgadget)\Entered = #False
        VectorSourceColor(GreyColour(RGBA(255,255,255,255)))
      Else
        VectorSourceColor(RGBA(255,255,255,255))
      EndIf  
      MovePathCursor(Offset + Height * 0.8, Height * 0.2)
      AddPathLine   (Offset + Height * 0.8, Height * 0.8)
      AddPathLine   (Offset + Height * 1.4, Height * 0.5)
      ClosePath     ()
      FillPath      ()
      
      ;Start Of Track
      If MyGadgetArray(Currentgadget)\Entered = #False
        VectorSourceColor(GreyColour(RGBA(255,0,0,255)))
      Else
        VectorSourceColor(RGBA(255,0,0,255))
      EndIf   
      AddPathCircle(Offset,Height * 0.5,Height * 0.4,270,90)
      StrokePath(Height /10)
    StopVectorDrawing()
   
  EndProcedure
    
  Procedure DrawGadget()
  ;{ ==Procedure Header Comment==============================
  ;        Name/title: DrawGadget
  ;       Description: Part of custom gadget template
  ;                  : Procedure to draw the gadget on the canvas
  ; 
  ; ====================================================
  ;}    
    
    ;Clear Current gadget
    StartDrawing(CanvasOutput(MyGadgetArray(Currentgadget)\Gadget_ID))
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0, 0, OutputWidth(),OutputHeight(), MyGadgetArray.MyGadget(CurrentGadget)\BackColour)
    StopDrawing()
    DrawLeft()
    DrawTrack()
    DrawRight()

  EndProcedure 
  
  Procedure DrawSlider(Value.d)
    
    Define Height.i,Width.i,OffSet.d  

    StartVectorDrawing(CanvasVectorOutput(MyGadgetArray(Currentgadget)\Gadget_ID)) 
  
      If MyGadgetArray(Currentgadget)\Vertical = #True
    
        Height = VectorOutputWidth()
        Width = VectorOutputHeight()
        RotateCoordinates((Height/2),(Height/2),90)
    
      Else 
    
        Height = VectorOutputHeight()
        Width = VectorOutputWidth()
    
      EndIf 
      If MyGadgetArray(Currentgadget)\Entered = #False
        VectorSourceColor(GreyColour(RGBA(0,255,0,255)))
      Else
        VectorSourceColor(RGBA(0,255,0,255))
      EndIf   

      Offset = (((Width - (Height * 3))/100) * Value) + Height * 1.5
      MyGadgetArray(Currentgadget)\Slidercentre = Offset
      MyGadgetArray(Currentgadget)\Ratio = (Width - (Height * 3))/100
      AddPathCircle(Offset,Height * 0.5,Height * 0.35)
      FillPath()
      
    StopVectorDrawing() 

  EndProcedure
  
  Procedure AddGadget(ThisWindow.i,ThisGadget.i)
 ;{ ==Procedure Header Comment==============================
;        Name/title: AddGadget
;       Description: Part of custom gadget template
;                  : Adds the Id of the newly created gadget to the gadget array
; ====================================================
;}
    
    MyGadgetArray(ArraySize(MyGadgetArray()))\Window_ID = ThisWindow
    MyGadgetArray(ArraySize(MyGadgetArray()))\Gadget_ID = ThisGadget
    ReDim MyGadgetArray(ArraySize(MyGadgetArray())+1)
    
  EndProcedure
  
  Procedure SendEvents(Event.i)
;{ ==Procedure Header Comment==============================
;        Name/title: SendEvents
;       Description: Part of custom gadget template
;                  : Used to send custom events to the main event loop
; ====================================================
;}   
    
    ;Post The Event
    PostEvent(#PB_Event_Gadget, MyGadgetArray(CurrentGadget)\Window_ID, MyGadgetArray(CurrentGadget)\Gadget_ID,Event,MyGadgetArray(CurrentGadget)\Value)
    
 EndProcedure
 
  Procedure RepeatScrollAction()
    
    Select ActionToRepeat
        
      Case 0
        RepeatAction = #False 
        If IsThread(thread)
          KillThread(thread)
        EndIf
        ProcedureReturn
      Case 1         
        Currentvalue = MyGadgetArray(CurrentGadget)\Value - 1
      Case 2
       Currentvalue = MyGadgetArray(CurrentGadget)\Value + 1
    EndSelect

    If Currentvalue < MyGadgetArray(CurrentGadget)\Minimum
      Currentvalue = MyGadgetArray(CurrentGadget)\Minimum
      RepeatAction = #False
      If IsThread(thread)
        KillThread(thread)
      EndIf     
      ProcedureReturn
    EndIf
    If Currentvalue > MyGadgetArray(CurrentGadget)\Maximum
      Currentvalue = MyGadgetArray(CurrentGadget)\Maximum
      RepeatAction = #False     
      If IsThread(thread)
        KillThread(thread)
      EndIf     
      ProcedureReturn      
    EndIf
    MyGadgetArray(CurrentGadget)\Value = Currentvalue
    SendEvents(#CGScrollChange)      
    DrawGadget()
    DrawSlider(MyGadgetArray(CurrentGadget)\Value)
    
  EndProcedure
 
  Procedure ActionTimer(RepeatTime.i)
    
    Static WaitTime.i
    WaitTime = 500
    t = ElapsedMilliseconds()
    Repeat
      s = ElapsedMilliseconds()
      If s-t => WaitTime
        WaitTime = 0
        If s-t => RepeatTime
          RepeatScrollAction()
          t = s
        EndIf
      EndIf
    
      Delay(5) ;keep cpu use in check
    Until RepeatAction = #False

  EndProcedure
 
 
  Procedure GadgetEvents()
  ;{ ==Procedure Header Comment==============================
;        Name/title: GadgetEvents
;       Description: Part of custom gadget template
;                  : Handles all events for this custom gadget
; ====================================================
;}
    
    SetCurrentGadgetID(EventGadget())
    
    Define Currentvalue.i
    
    Select EventType()
        
      Case #PB_EventType_MouseWheel
        
        If MyGadgetArray(CurrentGadget)\Entered = #True
          Currentvalue = MyGadgetArray(CurrentGadget)\Value - GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_WheelDelta )
          If Currentvalue < MyGadgetArray(CurrentGadget)\Minimum
            Currentvalue = MyGadgetArray(CurrentGadget)\Minimum
          EndIf
          If Currentvalue > MyGadgetArray(CurrentGadget)\Maximum
            Currentvalue = MyGadgetArray(CurrentGadget)\Maximum
          EndIf
          MyGadgetArray(CurrentGadget)\Value = Currentvalue
          SendEvents(#CGScrollChange)      
          DrawGadget()
          DrawSlider(MyGadgetArray(CurrentGadget)\Value)       
        EndIf     
          
      Case #PB_EventType_MouseEnter
        
        SetActiveGadget(MyGadgetArray(CurrentGadget)\Gadget_ID)
        MyGadgetArray(CurrentGadget)\Entered = #True
        DrawGadget()
        DrawSlider(MyGadgetArray(CurrentGadget)\Value)
        
      Case #PB_EventType_MouseLeave 
        
        SetActiveGadget(-1)
        RepeatAction = #False
        If IsThread(thread)
          KillThread(thread)
        EndIf
        MouseMoveSelect = #False
        MyGadgetArray(CurrentGadget)\Entered = #False
        DrawGadget()        
        DrawSlider(MyGadgetArray(CurrentGadget)\Value)      
        
      Case #PB_EventType_MouseMove 
        
        If MyGadgetArray(CurrentGadget)\Vertical = #True
          YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseY )
        Else
          YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseX )   
        EndIf      
        
        If MouseMoveSelect = #True
          
          currentvalue = (Ypos - (MyGadgetArray(CurrentGadget)\Height * 1.5)) / MyGadgetArray(CurrentGadget)\Ratio
          If currentvalue < MyGadgetArray(CurrentGadget)\Minimum
            currentvalue = MyGadgetArray(CurrentGadget)\Minimum
          EndIf
           If currentvalue > MyGadgetArray(CurrentGadget)\Maximum
            currentvalue = MyGadgetArray(CurrentGadget)\Maximum
          EndIf
          MyGadgetArray(CurrentGadget)\Value = currentvalue
          SendEvents(#CGScrollChange)
          Drawgadget()
          DrawSlider(currentvalue)
          
        EndIf
        
      Case #PB_EventType_LeftButtonDown
        
        RepeatAction = #True
        thread = CreateThread(@ActionTimer(),50)
        If MyGadgetArray(CurrentGadget)\Vertical = #True
          YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseY )
        Else
          YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseX )   
        EndIf 
        sliderpos = MyGadgetArray(CurrentGadget)\Slidercentre
        If ypos > Sliderpos - (MyGadgetArray(CurrentGadget)\Height/2) And Ypos < Sliderpos + (MyGadgetArray(CurrentGadget)\Height/2)
          MouseMoveSelect = #True
        EndIf
        ActionToRepeat = 0 
        If YPos < MyGadgetArray(CurrentGadget)\Height
          ActionToRepeat = 1
        ElseIf YPos > (MyGadgetArray(CurrentGadget)\Width - MyGadgetArray(CurrentGadget)\Height)
          ActionToRepeat = 2
        EndIf
      
      Case #PB_EventType_LeftButtonUp
        
        RepeatAction = #False
        If IsThread(thread)
          KillThread(thread)
        EndIf
        drawgadget()
        DrawSlider(MyGadgetArray(CurrentGadget)\Value)      
   
      Case #PB_EventType_LeftClick 
          
        If MouseMoveSelect = #True
          MouseMoveSelect = #False
        Else
    
          If MyGadgetArray(CurrentGadget)\Vertical = #True
            YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseY )
          Else
            YPos = GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Canvas_MouseX )   
          EndIf

          Select YPos
            
            Case 0 To MyGadgetArray(CurrentGadget)\Height
            
              MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Value - 1    
              If MyGadgetArray(CurrentGadget)\Value < MyGadgetArray(CurrentGadget)\Minimum
                MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Minimum
              EndIf
              SendEvents(#CGScrollChange)
              SendEvents(#CGScrollSmallFall)             
            
            Case (MyGadgetArray(CurrentGadget)\Width - MyGadgetArray(CurrentGadget)\Height) To MyGadgetArray(CurrentGadget)\Width
   
              MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Value + 1    
              If MyGadgetArray(CurrentGadget)\Value > MyGadgetArray(CurrentGadget)\Maximum
                MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Maximum
              EndIf
              SendEvents(#CGScrollChange)
              SendEvents(#CGScrollSmallRise)              
  
            Default
              
              Range.d = (MyGadgetArray(CurrentGadget)\Width - (MyGadgetArray(CurrentGadget)\Height * 2))/100
              Value.d  = (Range * MyGadgetArray(CurrentGadget)\Value) + MyGadgetArray(CurrentGadget)\Height
              
              If YPos  > Value
                MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Value + MyGadgetArray(CurrentGadget)\Page   
                If MyGadgetArray(CurrentGadget)\Value > MyGadgetArray(CurrentGadget)\Maximum
                  MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Maximum
                EndIf                
                SendEvents(#CGScrollLargeRise) 

              Else
                MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Value - MyGadgetArray(CurrentGadget)\Page   
                If MyGadgetArray(CurrentGadget)\Value < MyGadgetArray(CurrentGadget)\Minimum
                  MyGadgetArray(CurrentGadget)\Value  = MyGadgetArray(CurrentGadget)\Minimum
                EndIf               
                SendEvents(#CGScrollLargeFall) 
              EndIf
              SendEvents(#CGScrollChange)

          EndSelect  ;YPos           
          Drawgadget()
          DrawSlider(MyGadgetArray(CurrentGadget)\Value)
        EndIf
          
      EndSelect
 
  EndProcedure
  
  Procedure New(Gadget.i, x.i,y.i,width.i,height.i,Min.i,Max.i,Page.i,Flags.i=0)
    ;{ ==Procedure Header Comment==============================
;        Name/title: CreateGadget
;       Description: Part of custom gadget template
;                  : procedure to create the canvas used for the gadget
; ====================================================
;}  
    Define ThisWindow.i,ThisGadget.i,Vertical.i
    
    If Flags = #True
      Vertical = #True
      ;Create The Canvas For The Gadget
      If Gadget = #PB_Any
        ThisGadget = CanvasGadget(#PB_Any, x,y,height,width, #PB_Canvas_Keyboard)
      Else
        ThisGadget = Gadget
        CanvasGadget(Gadget, x,y,height,width, #PB_Canvas_Keyboard)
      EndIf    
    Else
      Vertical = #False
      ;Create The Canvas For The Gadget
      If Gadget = #PB_Any
        ThisGadget = CanvasGadget(#PB_Any, x,y,width,height, #PB_Canvas_Keyboard)
      Else
        ThisGadget = Gadget
        CanvasGadget(Gadget, x,y,width,height, #PB_Canvas_Keyboard)      
      EndIf
    EndIf

    ;Bind This Gadgets Events
    If IsGadget(ThisGadget)   
       BindGadgetEvent(ThisGadget, @GadgetEvents())
    EndIf
    
    ;The Window On Which It Is Created
    ThisWindow = GetActiveWindow()

    ;Add the window id as data to the gadget
    SetGadgetData(ThisGadget,ThisWindow)    
    
    ;Add To The Custom Gadget Array
    AddGadget(ThisWindow,ThisGadget)

    SetCurrentGadgetID(ThisGadget)
    
    ;Get background colour where gadget will be drawn
    StartDrawing(WindowOutput(ThisWindow))
      MyGadgetArray.MyGadget(CurrentGadget)\BackColour = Point(x, y)
    StopDrawing()
    
    ;Set Colour Of Canvas To Background
    StartDrawing(CanvasOutput(ThisGadget))
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0, 0, OutputWidth(), OutputHeight(), MyGadgetArray.MyGadget(CurrentGadget)\BackColour)
    StopDrawing()
      
    ;Save Settings For This Gadget
    MyGadgetArray.MyGadget(CurrentGadget)\Vertical = Vertical  
    MyGadgetArray.MyGadget(CurrentGadget)\Width = Width
    MyGadgetArray.MyGadget(CurrentGadget)\Height = Height
    MyGadgetArray.MyGadget(CurrentGadget)\Minimum = Min
    MyGadgetArray.MyGadget(CurrentGadget)\Maximum = Max
    MyGadgetArray.MyGadget(CurrentGadget)\Page = Page   
    MyGadgetArray.MyGadget(CurrentGadget)\Value = 0

    ;Draw the actual gadget
    DrawGadget()
    DrawSlider(MyGadgetArray.MyGadget(CurrentGadget)\Value)
    
    ProcedureReturn ThisGadget 
    
  EndProcedure 
    
EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 28
; FirstLine = 6
; Folding = lAwx
; EnableXP