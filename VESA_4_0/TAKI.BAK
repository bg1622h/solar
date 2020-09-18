{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,655360}
uses vesa,objects,keyboard;
type vec=array[0..4] of integer;
const di:vec=(0,0,+1,0,-1);
      dj:vec=(0,+1,0,-1,0);
const n=8;
      maxnumt=8;
      kzone=4;
type tobject=record
     di,dj,offs,hp,nnuldi,nnuldj:integer;{t[at]}
     oldx,oldy:array[0..1] of integer;
     end;
type tekr=array[-1..n,-1..n] of integer;
type ttank=record
     dj,di,offs,hp:integer;
     oldx,oldy:array[0..1] of integer;
     end;
type ttanks=array[1..maxnumt] of ttank;
type tpick=array[-1..1,-1..1] of pointer;
type tbullet=record
     dist,di,dj,target:integer;
     oldxekr,oldyekr:array[0..1] of integer;
     f:boolean; {dist-сколько летит пуля в пикселях}
     end;
type tflybull=record
     m:array[1..3200] of tbullet;
     size:integer;
     end; {INF}
var ekr:tekr;
    sizezonx,sizezony,page,numt,pointx,pointy,sizex,sizey:integer;
    pic:array[0..3] of pointer;
    all:array[0..1] of boolean;
    pickenemy,pickplayer,pickpylya:tpick;
    player:tobject;
    t:ttanks;
    flybull:tflybull;
procedure readmap;
var i,j:integer;
    c:char;
    f:text;
begin
     assign(f,'map.txt');
     reset(f);
     for i:=0 to n-1 do
     begin
     for j:=0 to n-1 do
     begin
         read(f,c);
         ekr[i,j]:=ord(c)-ord('0');
     end;
     readln(f);
     end;
     close(f);
     for i:=-1 to n do
     begin
          ekr[-1,i]:=255;
          ekr[n,i]:=255;
          ekr[i,-1]:=255;
          ekr[i,n]:=255;
     end;
end;
procedure load;
var f:file;
    i:integer;
    a:pointer;
begin
     assign(f,'allspr.dat');
     reset(f,1);
     pic[0]:=loadspr1(f);
     pic[1]:=loadspr1(f);
     a:=loadspr1(f); {RLUD} {di,dj}
     pickenemy[0,1]:=a;
     a:=loadspr1(f);
     pickenemy[0,-1]:=a;
     a:=loadspr1(f);
     pickenemy[-1,0]:=a;
     a:=loadspr1(f);
     pickenemy[1,0]:=a;
     a:=loadspr1(f); {RLUD} {di,dj}
     pickplayer[0,1]:=a;
     a:=loadspr1(f);
     pickplayer[0,-1]:=a;
     a:=loadspr1(f);
     pickplayer[-1,0]:=a;
     a:=loadspr1(f);
     pickplayer[1,0]:=a;
     close(f);
     {только траву для теста}
end;
procedure playershot; {ПОКА ЧТО УЧИМ ПОЛЬЗОВАТЕЛЯ СТРЕЛЯТЬ}
{на пробел}
var i:byte;
begin
     inc(flybull.size);
     for i:=0 to 1 do
     begin
     flybull.m[flybull.size].oldxekr[i]:=(player.nnuldj+player.oldx[page])*sizezonx;
     flybull.m[flybull.size].oldyekr[i]:=(player.nnuldi+player.oldy[page])*sizezony;
     end;
     {если бы матрица без скроллов}
     flybull.m[flybull.size].dist:=200;
     flybull.m[flybull.size].dj:=player.nnuldj;
     flybull.m[flybull.size].di:=player.nnuldi;
     flybull.m[flybull.size].f:=false;
     flybull.m[flybull.size].target:=1;{1 противник -1 игрок}
end;
function bvisual(t:tbullet):boolean;
begin
     bvisual:=(t.oldxekr[page] div sizezonx>=pointx)
     and (t.oldxekr[page] div sizezonx<=pointx+kzone) and
     (t.oldyekr[page] div sizezony>=pointy)
     and (t.oldyekr[page] div sizezony<=pointy+kzone)
end;
procedure writeallfbull;
var i,xekr,yekr,dist,di,dj:integer;
begin
     {Стер прошлое нарисовал новое}
     for i:=1 to flybull.size do
     begin
          xekr:=flybull.m[i].oldxekr[page];
          yekr:=flybull.m[i].oldyekr[page];
          dist:=flybull.m[i].dist;
          di:=flybull.m[i].di;
          dj:=flybull.m[i].dj;
          {write(xekr div sizezonx ,' ',yekr div sizezony);}
          if (ekr[yekr div sizezony,xekr div sizezonx]<>0)
          and ((player.oldx[page]<>xekr div sizezonx) or (
          player.oldy[page]<>yekr div sizezony))
          then
          begin
          flybull.m[i]:=flybull.m[flybull.size];
          writeln('adxschba');
          dec(flybull.size);
          end;{добавляем к взрыву {target,xekr,yekr} {для теста просто затрем}
               if bvisual(flybull.m[i])
               then begin
               putsprite(xekr-pointx*sizezonx,yekr-pointy*sizezony,pic[0]);
               if (ekr[(yekr+di*dist) div sizezony,(xekr+dj*dist) div sizezonx]=0)
               then
               putsprite((xekr+di*dist)-pointx*sizezonx,(yekr+dj*dist)-pointy*sizezony,pic[0]);
          putsprite(xekr,yekr,pickpylya[di,dj]);
          inc(yekr,dist*di);
          inc(xekr,dist*dj);
          end
          else begin
               inc(xekr,dist*dj);
               inc(yekr,dist*di);
               end;
     flybull.m[i].f:=true;
     end;
end;
function readxod:integer;
var c:char;
begin
     if keys[kright]
     then begin readxod:=1; exit; end;
     if keys[kdown]
     then begin readxod:=2; exit; end;
     if keys[kleft]
     then begin readxod:=3; exit; end;
     if keys[kup]
     then begin readxod:=4; exit; end;
     if keys[kspace]
     then begin playershot;  end;
     readxod:=0;

end;
procedure init;
var rx:integer;
begin
     sizex:=0;
     sizey:=0;
     page:=0;
     numt:=0;
     pointx:=0;
     pointy:=0;
     player.hp:=100;
     rx:=readxod;
     player.di:=di[rx];
     player.dj:=dj[rx];
     player.nnuldi:=di[rx];
     player.nnuldj:=dj[rx];
     pickplayer[0,0]:=pickplayer[0,-1];
     player.oldx[page]:=0;
     player.oldy[page]:=0;
     player.oldx[1-page]:=0;
     player.oldy[1-page]:=0;
     player.offs:=0;
     ekr[0,0]:=255;
     sizezonx:=256;
     sizezony:=192;
     all[0]:=true;
     all[1]:=true;
end;
{движение}
procedure playermove;
var rx,i,xekr,yekr:integer;
begin
     putsprite(sizezonx*(player.oldx[page]-pointx),sizezony*(player.oldy[page]-pointy),pic[0]);
     putsprite(sizezonx*(player.oldx[page]+player.dj-pointx),sizezony*(player.oldy[page]+player.di-pointy),pic[0]);
     if player.offs=32
     then begin
          ekr[player.oldy[page],player.oldx[page]]:=0;
          for i:=0 to 1 do
          begin
          inc(player.oldx[i],player.dj);
          inc(player.oldy[i],player.di);
          end;
          ekr[player.oldy[page],player.oldx[page]]:=255;
          rx:=readxod;
          pickplayer[0,0]:=pickplayer[player.di,player.dj];
          if (player.di<>0) or (player.dj<>0)
          then begin
          player.nnuldi:=player.di;
          player.nnuldj:=player.dj;
          end;
          if ekr[player.oldy[page]+di[rx],player.oldx[page]+dj[rx]]<>0
          then begin player.di:=0; player.dj:=0; end
          else begin player.di:=di[rx]; player.dj:=dj[rx];
          player.nnuldi:=di[rx];
          player.nnuldj:=dj[rx];
          player.offs:=0;
          end;
     end
     else begin
     if (player.di=0) and (player.dj=0)
     then begin rx:=readxod; player.di:=di[rx];
     player.dj:=dj[rx]; end
     else inc(player.offs);
     end;
    { writeln(player.oldx[page],' ', player.oldy[page]);}
     xekr:=(player.oldx[page]-pointx)*sizezonx+player.dj*player.offs*(sizezonx div 32);
     yekr:=(player.oldy[page]-pointy)*sizezony+player.di*player.offs*(sizezony div 32);
     putsprite(xekr,yekr,pickplayer[player.di,player.dj]);
    { writeln(player.di,' ',player.dj);}
    { write(xekr,' ',yekr); }
end;{надежная как швейцарские часы}
procedure nextstep(var t:ttank); {бот}
type tpoint=record
     i,j:integer;
     end;
const INF=32000;
var g,xv,l,i,j,min,last:integer;
    pole,volna:tekr;
    tek:tpoint;
    q:array[1..64] of tpoint;
procedure putq(x:tpoint);
begin
     if l<64
     then begin
     inc(xv);
     if xv>64 then xv:=1;
     q[xv]:=x;
     inc(l);
     end;
end;
procedure getq(var x:tpoint);
begin
     if l>0
     then begin
          x:=q[g];
          inc(g);
          if g>64 then g:=1;
          dec(l);
     end;
end;
begin{чтобы были пули танк не будем двигать}

     {for i:=0 to n-1 do
         for j:=0 to n-1 do
             volna[i,j]:=INF;
     pole:=ekr;
     pole[player.oldy[page],player.oldx[page]]:=0;
     pole[t.oldy[page],t.oldx[page]]:=0;
     volna[player.oldy[page],player.oldx[page]]:=0;
     g:=1;
     xv:=0;
     l:=0;
     tek.i:=player.oldy[page];
     tek.j:=player.oldx[page];
     putq(tek);
     while l>0 do
     begin
          getq(tek);
          for i:=1 to 4 do
          begin
          if (pole[tek.i+di[i],tek.j+dj[i]]=0) and (volna[tek.i+di[i],tek.j+dj[i]]=INF)
          then begin volna[tek.i+di[i],tek.j+dj[i]]:=volna[tek.i,tek.j]+1;
          inc(tek.i,di[i]);
          inc(tek.j,dj[i]);
          putq(tek);
          end;
          end;
     end;
     {writeln(t.oldx[page],' ',t.oldy[page]);}
     {восстановим путь}
     {tek.i:=t.oldy[page];
     tek.j:=t.oldx[page];
    { for i:=0 to n-1 do
     begin
          for j:=0 to n-1 do
          write(volna[i,j],'  ');
     writeln;
     writeln;
     end;
     writeln;}
     {while volna[tek.i,tek.j]<>0 do
     begin
          last:=0;
          min:=INF;
          for i:=1 to 4 do
          begin
               if (min>volna[tek.i+di[i],tek.j+dj[i]])
               and (tek.i+di[i]>-1) and (tek.i+di[i]<n)
                and (tek.j+dj[i]>-1) and (tek.j+dj[i]<n)
               then begin last:=i; min:=volna[tek.i+di[i],tek.j+dj[i]]; end;
          end;
           if (last=0) or (min=INF)
           then break
           else begin inc(tek.i,di[last]); inc(tek.j,dj[last]); end;
     end;
     if (ekr[t.oldy[page]+di[last],t.oldx[page]+dj[last]]<>0)
     then last:=0;
     t.di:=di[last];
     t.dj:=dj[last];
     writeln(last);}
end;
procedure analizpr(var t:ttank);
var i,j:integer;
begin
          if t.offs=32
          then begin
               pickenemy[0,0]:=pickenemy[t.di,t.dj];
               ekr[t.oldy[page],t.oldx[page]]:=0;
               for j:=0 to 1 do
               begin
                    inc(t.oldx[j],t.dj);
                    inc(t.oldy[j],t.di);
               end;
               ekr[t.oldy[page],t.oldx[page]]:=255;
               {writeln(t.oldy[page],' ',t.oldx[page]);}
               t.offs:=0;
               if (ekr[t.oldy[page]+t.di,t.oldx[page]+t.dj]<>0)
               then nextstep(t);
          end
          else inc(t.offs);
end;
function iamvisual(t:ttank):boolean;
begin
     iamvisual:=(t.oldx[page]>=pointx) and (t.oldx[page]<pointx+kzone) and
     (t.oldy[page]>=pointy) and (t.oldy[page]<pointy+kzone);
end;
procedure writenemytanks;
var i:byte;
    xekr,yekr:integer;
begin
     {стер нарисовал}
     for i:=1 to numt do
     begin
          if iamvisual(t[i])
          then begin
               putsprite(sizezonx*(t[i].oldx[page]-pointx),sizezony*(t[i].oldy[page]-pointy),pic[0]);
               putsprite(sizezonx*(t[i].oldx[page]+t[i].dj-pointx),sizezony*(t[i].oldy[page]+t[i].di-pointy),pic[0]);
               analizpr(t[i]);
               xekr:=(t[i].oldx[page]-pointx)*sizezonx+t[i].dj*t[i].offs*(sizezonx div 32);
               yekr:=(t[i].oldy[page]-pointy)*sizezony+t[i].di*t[i].offs*(sizezony div 32);
               putsprite(xekr,yekr,pickenemy[t[i].di,t[i].dj]);
          end
          else analizpr(t[i]); {тех что нет тоже двигаем}
     end;
end;
procedure gen;
var x,y,i:integer;
begin
     inc(numt);
     t[numt].hp:=random(100)+100;
     x:=random(n);
     y:=random(n);
     while ekr[y,x]<>0 do
     begin
     x:=random(n);
     y:=random(n);
     end;
     for i:=0 to 1 do
     begin
          t[numt].oldx[i]:=x;
          t[numt].oldy[i]:=y;
     end;
     writeln(t[numt].oldx[page],' ',t[numt].oldy[page]);
     ekr[t[numt].oldy[page],t[numt].oldx[page]]:=255;
     nextstep(t[numt]);
     {t[numt].di:=0;
     t[numt].dj:=0;
     t[numt].di:=0;
     t[numt].dj:=0;}
     if (t[numt].di=0) and (t[numt].dj=0)
     then pickenemy[0,0]:=pickenemy[0,-1]
     else pickenemy[0,0]:=pickenemy[t[numt].di,t[numt].dj];
end;
procedure generation;
var i:integer;
begin
     for i:=1 to 3 do
         gen;
end;
{скроллинг}
procedure countpos;
begin
     if player.oldx[page]>=pointx+kzone
     then begin
          if pointx+kzone<n
          then begin player.oldx[1-page]:=player.oldx[page]; inc(pointx,kzone);
          all[0]:=true; all[1]:=true;  end;
     end;
     if player.oldx[page]<pointx
     then begin
          if pointx-kzone>-1
          then begin player.oldx[1-page]:=player.oldx[page]; dec(pointx,kzone);
          all[0]:=true; all[1]:=true;  end;
     end;
     if player.oldy[page]>=pointy+kzone
     then begin
          if pointy+kzone<n
          then begin player.oldy[1-page]:=player.oldy[page];  inc(pointy,kzone);
          all[0]:=true; all[1]:=true;  end;
     end;
     if player.oldy[page]<pointy
     then begin
          if pointy-kzone>-1
          then begin player.oldy[1-page]:=player.oldy[page];  dec(pointy,kzone);
          all[0]:=true; all[1]:=true; end;
     end;
end;
procedure newpic;
var i,j,ki,kj:integer;
begin
        for i:=0 to kzone-1 do
         for j:=0 to kzone-1 do
         if ekr[i+pointy,j+pointx] in [0,1,2]
         then putsprite(j*sizezonx,i*sizezony,pic[ekr[i+pointy,j+pointx]]);
end;
begin
     randomize;
     readmap;
     initall(m1024x768);
     keyboardinit;
     {до обнулять не забудь}
     {а еще спрайты загружать}
     load;
     init;
     generation;
     {showmouse;}
     repeat
           setvisualpage(page);
           page:=1-page;
           waitvbl;
           setactivepage(page);
           countpos;
           if all[page]
           then begin
           all[page]:=false;
           newpic;
          { writeln(page);
           writeln(player.oldx[0],' ',player.oldx[1]);
           writeln(player.oldy[0],' ',player.oldy[1]);}
           end;
           writenemytanks;
           playermove;
           writeallfbull;
     until (player.hp=0) or (keys[kesc]);
     doneall;
end. {0 будет трава}
{танки каждый сам за себя но вообще это можно исправить но оно мне надо?
(да надо)}
{РАЗРУШАЕМЫЕ СТЕНЫ ЗАВТРА}
{предыдущее новая позиция новое изображение}