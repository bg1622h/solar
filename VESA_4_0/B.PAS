uses crt,vesa;
var  p,p1:pointer;
     x,y:integer;
     page:byte;
begin
     initall(m1024x768);
     p:=loadspr('armatar.spr');
     p1:=loadspr('r.spr');
     x:=100;
     y:=500;
     page:=0;
     repeat
     setvisualpage(page);
     page:=1-page;
     waitvbl;
     setactivepage(page);
     setcolor(0); {снача затираем потом ставим изображение}
     bar(0,0,1024,768);
     putsprite(x,y,p);
     putsprite(x,y+100,p1);
     inc(x);
     until keypressed;
     doneall;
end.