uses crt,vesa;
var p:pointer;
    x,y:integer;
    page:byte;
begin
  InitAll(m640x480);
  p:=LoadSpr('r.spr');
  x:=0;
  y:=100;
  Page:=0;
  repeat
   SetVisualPage(Page);
   Page:=1-Page;
   WaitVBL;
   SetActivePage(Page);
   setcolor(0);
   bar(x-1,y,x+60,y+70);
   delay(10);
   PutSprite(x,y,p);
   inc(x);
  until keypressed;
  Doneall;
end.