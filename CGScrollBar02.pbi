
#CGScrollVertical = 1

DeclareModule CGScrollBar02
  
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

Module CGScrollBar02

  ;The Main Gadget Structure
  Structure MyGadget
    Window_ID.i
    Gadget_ID.i
    BackColour.i
    GadgetColour.i
    TrackColour.i
    ButtonColour.i
    ArrowColour.i
    imgTrack.i
    imgSlider.i
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
  
  Procedure GetWindowBackgroundColor(hwnd=0) ;hwnd only used in Linux, ignored in Win/Mac
    
    CompilerSelect #PB_Compiler_OS
     
      CompilerCase #PB_OS_Windows 
        Protected color = GetSysColor_(#COLOR_WINDOW)
        If color = $FFFFFF Or color=0
          color = GetSysColor_(#COLOR_BTNFACE)
        EndIf
        ProcedureReturn color
     
      CompilerCase #PB_OS_Linux   ;thanks to uwekel http://www.purebasic.fr/english/viewtopic.php?p=405822
        Protected *style.GtkStyle, *color.GdkColor
        *style = gtk_widget_get_style_(hwnd) ;GadgetID(Gadget))
        *color = *style\bg[0]                ;0=#GtkStateNormal
        ProcedureReturn RGB(*color\red >> 8, *color\green >> 8, *color\blue >> 8)
     
      CompilerCase #PB_OS_MacOS   ;thanks to wilbert http://purebasic.fr/english/viewtopic.php?f=19&t=55719&p=497009
        Protected.i color, Rect.NSRect, Image, NSColor = CocoaMessage(#Null, #Null, "NSColor windowBackgroundColor")
        If NSColor
          Rect\size\width = 1
          Rect\size\height = 1
          Image = CreateImage(#PB_Any, 1, 1)
          StartDrawing(ImageOutput(Image))
          CocoaMessage(#Null, NSColor, "drawSwatchInRect:@", @Rect)
          color = Point(0, 0)
          StopDrawing()
          FreeImage(Image)
          ProcedureReturn color
        Else
          ProcedureReturn -1
        EndIf
    CompilerEndSelect
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
    
      For iLoop = 0 To ArraySize(MyGadgetArray()) -1

        If Gadget = MyGadgetArray(iLoop)\Gadget_ID

          CurrentGadget = iLoop
        Break
        EndIf
      
      Next iLoop 
  
  EndProcedure
  
  Procedure.i ColourDarken (Color.i, Fact.d)
  
  ; [by Oma, 2016-04-21]
  Protected.i Red, Green, Blue, Alpha
      
  If Fact > 1.0 
    Fact = 1.0 
  EndIf
  Alpha = Alpha(Color)
  Red   = Red(Color)   * Fact
  Green = Green(Color) * Fact
  Blue  = Blue(Color)  * Fact
      
  ProcedureReturn RGBA(Red, Green, Blue, Alpha)
  
EndProcedure

  Procedure Arrow(x.i,y.i,Size.i)
      
    VectorSourceColor(MyGadgetArray(Currentgadget)\ArrowColour)
         
    MovePathCursor(x -2 + Size * 0.5, y + Size * 0.5)
    AddPathLine   (x + Size, y + Size * 0.5)
    StrokePath(Size * 0.3)
         
    MovePathCursor(x + Size * 0.5, y)
    AddPathLine   (x + Size * 0.5,  y + Size)
    AddPathLine   (x, y + Size * 0.5)
    ClosePath()
    FillPath()
         
  EndProcedure
  
  Procedure.i CreateTrack()
       
    Define Width.d,Height.d,TempTrackImage.i
   
    Width = MyGadgetArray(Currentgadget)\Width
    Height = MyGadgetArray(Currentgadget)\Height
      
    Define TempTrackImage  
    TempTrackImage = CreateImage(#PB_Any,Width, Height, 32,#PB_Image_Transparent)
    If TempTrackImage
   
      
      ;Draw The Gadget
      StartVectorDrawing(ImageVectorOutput(TempTrackImage))
      
      ;Background
      VectorSourceColor(MyGadgetArray(CurrentGadget)\BackColour)
        AddPathBox(0,0,Width,Height)
      FillPath()
      
      ;Gadget
      VectorSourceLinearGradient(0, 0,0,Height)
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\GadgetColour,0.8), 0.0)
      VectorSourceGradientColor(MyGadgetArray(Currentgadget)\GadgetColour, 0.2)   
      VectorSourceGradientColor(MyGadgetArray(Currentgadget)\GadgetColour, 0.8)         
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\GadgetColour,0.8), 1.0) 
      MovePathCursor(height * 0.5,height * 0.5)
      AddPathLine(width-(height * 0.5),height * 0.5)
      StrokePath(height,#PB_Path_RoundEnd)    
      
      ;Draw the track
      VectorSourceLinearGradient(0, 0,0,Height)
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\TrackColour,0.4), 0.0)
      VectorSourceGradientColor(MyGadgetArray(Currentgadget)\TrackColour, 0.5)      
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\TrackColour,0.4), 1.0) 
      MovePathCursor(height,Height * 0.5)
      AddPathLine(Width-height,Height * 0.5)
      StrokePath(Height * 0.8)
      
      ;Left Button
      VectorSourceCircularGradient(Height * 0.5, Height * 0.5, Height * 0.5) 
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\ButtonColour,0.1), 0.0)       
      VectorSourceGradientColor(MyGadgetArray(Currentgadget)\ButtonColour, 1.0)
      AddPathCircle(Height * 0.5, Height * 0.5, Height * 0.35)
      FillPath() 
      Arrow(Height * 0.25,Height * 0.25,Height * 0.5)
      
      ;Right Button
      VectorSourceCircularGradient(Width - (Height * 0.5), Height * 0.5, Height * 0.5) 
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(Currentgadget)\ButtonColour,0.1), 0.0)       
      VectorSourceGradientColor(MyGadgetArray(Currentgadget)\ButtonColour, 1.0)     
      AddPathCircle(Width - (Height * 0.5), Height * 0.5, Height * 0.35)   
      FillPath()
      FlipCoordinatesX(Width * 0.5)
      Arrow(Height * 0.25,Height * 0.25,Height * 0.5)

      StopVectorDrawing()
      
    EndIf
      
    ProcedureReturn TempTrackImage
      
   EndProcedure
   
  Procedure.i CreateSlider()
    
    Define Height.d,TempSlider.i

    Height = MyGadgetArray(Currentgadget)\Height
     
    TempSlider = CreateImage(#PB_Any,Height, Height, 32,#PB_Image_Transparent)
    If TempSlider
      
      ;Set Correct BackColour for antialiasing
      StartDrawing(ImageOutput(TempSlider))
      DrawingMode(#PB_2DDrawing_Transparent)
      Box(0, 0, Height, Height, RGBA(255, 255, 255, 0))
      StopDrawing()      
      
      StartVectorDrawing(ImageVectorOutput(TempSlider))
      VectorSourceCircularGradient(Height * 0.5, Height * 0.5, Height * 0.5) 
      VectorSourceGradientColor(ColourDarken(MyGadgetArray(CurrentGadget)\ButtonColour,0.7), 0.0)       
      VectorSourceGradientColor(MyGadgetArray(CurrentGadget)\ButtonColour, 1.0)     
      AddPathCircle(Height * 0.5, Height * 0.5, Height * 0.5)   
      FillPath()
      
      StopVectorDrawing()
   EndIf   
   
   ProcedureReturn TempSlider

  EndProcedure 
  
  Procedure Cleargadget()
    
    ;Clear Current gadget
    StartDrawing(CanvasOutput(MyGadgetArray(Currentgadget)\Gadget_ID))
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0, 0, OutputWidth(),OutputHeight(), MyGadgetArray.MyGadget(CurrentGadget)\BackColour)
    StopDrawing()
      
  EndProcedure
    
  Procedure DrawGadget()
  ;{ ==Procedure Header Comment==============================
  ;        Name/title: DrawGadget
  ;       Description: Part of custom gadget template
  ;                  : Procedure to draw the gadget on the canvas
  ; 
  ; ====================================================
  ;}    
    Define Height.i,Width.i,OffSet.d,SAlpha.i,Value.i
    

    Value = MyGadgetArray(CurrentGadget)\Value
    
      If MyGadgetArray(Currentgadget)\Entered = #False
        SAlpha = 100
      Else
        SAlpha = 255
      EndIf

    StartVectorDrawing(CanvasVectorOutput(MyGadgetArray(Currentgadget)\Gadget_ID)) 
  
      If MyGadgetArray(Currentgadget)\Vertical = #True
    
        Height = VectorOutputWidth()
        Width = VectorOutputHeight()
        RotateCoordinates((Height/2),(Height/2),90)
    
      Else 
    
        Height = VectorOutputHeight()
        Width = VectorOutputWidth()
    
      EndIf 

      Offset = (((Width - (Height * 3))/100) * Value) + Height
      MyGadgetArray(Currentgadget)\Slidercentre = Offset + (Height * 0.5)
      MyGadgetArray(Currentgadget)\Ratio = (Width - (Height * 3))/100
      MovePathCursor(0,0)
      DrawVectorImage(ImageID(MyGadgetArray(Currentgadget)\imgTrack),SAlpha)     
      MovePathCursor(Offset,0)
      DrawVectorImage(ImageID(MyGadgetArray(Currentgadget)\imgSlider),255)
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
        ;Stop The Thread
        RepeatAction = #False 

        ProcedureReturn
      Case 1         
        Currentvalue = MyGadgetArray(CurrentGadget)\Value - 1
      Case 2
       Currentvalue = MyGadgetArray(CurrentGadget)\Value + 1
    EndSelect

    If Currentvalue < MyGadgetArray(CurrentGadget)\Minimum
      Currentvalue = MyGadgetArray(CurrentGadget)\Minimum
      RepeatAction = #False
    
      ProcedureReturn
    EndIf
    If Currentvalue > MyGadgetArray(CurrentGadget)\Maximum
      Currentvalue = MyGadgetArray(CurrentGadget)\Maximum
      RepeatAction = #False     
      ProcedureReturn      
    EndIf
    MyGadgetArray(CurrentGadget)\Value = Currentvalue
    SendEvents(#CGScrollChange)      
    DrawGadget()
    
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
    
      Delay(1) ;keep cpu use in check
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
        EndIf     
          
      Case #PB_EventType_MouseEnter
        
        SetActiveGadget(MyGadgetArray(CurrentGadget)\Gadget_ID)
        MyGadgetArray(CurrentGadget)\Entered = #True
        Cleargadget()
        DrawGadget()
        
      Case #PB_EventType_MouseLeave 
        
        SetActiveGadget(-1)
        RepeatAction = #False
        MouseMoveSelect = #False
        MyGadgetArray(CurrentGadget)\Entered = #False
        Cleargadget()
        DrawGadget()        

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
          
        EndIf
        
      Case #PB_EventType_LeftButtonDown

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
          RepeatAction = #True
          thread = CreateThread(@ActionTimer(),50)         
        ElseIf YPos > (MyGadgetArray(CurrentGadget)\Width - MyGadgetArray(CurrentGadget)\Height)
          ActionToRepeat = 2
          RepeatAction = #True
          thread = CreateThread(@ActionTimer(),50)        
        EndIf
      
      Case #PB_EventType_LeftButtonUp
        
        RepeatAction = #False
        Drawgadget()
   
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
    
    MyGadgetArray.MyGadget(CurrentGadget)\BackColour = GetWindowBackgroundColor(WindowID(ThisWindow))

    ;Set Colour Of Canvas To Background
    StartDrawing(CanvasOutput(ThisGadget))
      Box(0, 0, OutputWidth(), OutputHeight(), MyGadgetArray.MyGadget(CurrentGadget)\BackColour)
    StopDrawing()
    
    ;Save Settings For This Gadget
    MyGadgetArray(CurrentGadget)\Vertical = Vertical  
    MyGadgetArray(CurrentGadget)\Width = Width
    MyGadgetArray(CurrentGadget)\Height = Height
    MyGadgetArray(CurrentGadget)\Minimum = Min
    MyGadgetArray(CurrentGadget)\Maximum = Max
    MyGadgetArray(CurrentGadget)\Page = Page   
    MyGadgetArray(CurrentGadget)\Value = 50
    MyGadgetArray(CurrentGadget)\GadgetColour = RGBA(255,0,0,255)
    MyGadgetArray(CurrentGadget)\ButtonColour = RGBA(0,255,0,255)
    MyGadgetArray(CurrentGadget)\TrackColour = RGBA(236,236,236,255)
    MyGadgetArray(CurrentGadget)\ArrowColour = RGBA(255,255,255,255)
    MyGadgetArray(CurrentGadget)\imgTrack = CreateTrack()
    MyGadgetArray(CurrentGadget)\imgSlider = CreateSlider()
    
    ;Draw the actual gadget
    DrawGadget()
    
    ProcedureReturn ThisGadget 
    
  EndProcedure 
    
EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 475
; FirstLine = 249
; Folding = F4Aq
; EnableXP