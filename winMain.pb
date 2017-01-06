
IncludeFile "CGScrollBar00.pbi"
IncludeFile "CGScrollBar01.pbi"

Enumeration FormGadget
  #btnRedraw  
  #VScroll
  #HScroll
  #strVertValue
  #strHorzValue
  #cnvScrollBits  
EndEnumeration

Global Window_0,CustomGadget3.i,CustomGadget4.i

  Window_0 = OpenWindow(#PB_Any, 0, 5, 580, 400, "ScrollBar Test", #PB_Window_SystemMenu)
  CGScrollBar00::New(#VScroll,490, 10, 300,20,0,100,5,#CGSCRollVertical)
  CGScrollBar01::New(#HScroll,40, 310, 450,40,0,100,15)
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
          
        Case #VScroll

          Select EventType()
              
            Case CGScrollBar01::#CGScrollChange
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar01::#CGScrollSmallRise
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar01::#CGScrollLargeRise
              
              SetGadgetText(#strVertValue,Str(EventData())) 
              
            Case CGScrollBar01::#CGScrollLargeFall
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
            Case CGScrollBar01::#CGScrollSmallFall
              
              SetGadgetText(#strVertValue,Str(EventData()))
              
          EndSelect        
       
        Case #HScroll

          Select EventType()
              
            Case CGScrollBar00::#CGScrollChange
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar00::#CGScrollSmallRise
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar00::#CGScrollLargeRise
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar00::#CGScrollLargeFall
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
            Case CGScrollBar00::#CGScrollSmallFall
              
              SetGadgetText(#strHorzValue,Str(EventData()))
              
          EndSelect  
          
      EndSelect
  
  EndSelect
  
ForEver
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 61
; FirstLine = 55
; EnableXP