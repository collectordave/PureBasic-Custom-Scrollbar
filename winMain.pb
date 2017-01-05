
IncludeFile "CGScrollBar.pbi"

Enumeration FormGadget
  #btnRedraw  
  #CustomGadget1
  #CustomGadget2
  #strVertValue
  #strHorzValue
  #cnvScrollBits  
EndEnumeration

Global Window_0,CustomGadget3.i,CustomGadget4.i

  Window_0 = OpenWindow(#PB_Any, 0, 5, 580, 400, "ScrollBar Test", #PB_Window_SystemMenu)
  CGScrollBar::New(#CustomGadget1,490, 10, 300,20,0,100,5,#CGSCRollVertical)
  CGScrollBar::New(#CustomGadget2,40, 310, 450,40,0,100,15)
  StringGadget(#strVertValue, 520, 140, 50, 20, "")
  StringGadget(#strHorzValue, 220, 360, 50, 20, "")
  CanvasGadget(#cnvScrollBits, 40, 10, 450, 300)
  
  Repeat
    
  Event = WaitWindowEvent()
    
  Select Event
    Case #PB_Event_CloseWindow
      
      End

    Case #PB_Event_Gadget

      Select EventGadget()
          
        Case #CustomGadget1

          Select EventType()
              
            Case CGScrollBar::#CGScrollChange
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollSmallRise
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollLargeRise
              
              SetGadgetText(#strVertValue,Str(EventData())) 
              
            Case CGScrollBar::#CGScrollLargeFall
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollSmallFall
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
          EndSelect        
       
        Case #CustomGadget2

          Select EventType()
              
            Case CGScrollBar::#CGScrollChange
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollSmallRise
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollLargeRise
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollLargeFall
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar::#CGScrollSmallFall
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
          EndSelect  
          
      EndSelect
  
  EndSelect
  
ForEver
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 16
; EnableXP