{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,655360}
type
ident=(cmprog,cmif,cmthen,cmelse,cmendif,cmbegin,cmend,cmfor,cmto,cmint,
cmtz,cmtt,cmzp,cmleft,cmright,cmup,cmdown,cmequ,
cmnumber,cmless,cmmore,cmnotequ,cmlesseq,cmmoreeq,cmident);
str_15=string[15];
     tvar_name=array[1..50] of str_15;
     tvar=record
                name:str_15;
                znach:integer; {мб добавлю double}
                type_:ident;
     end;
tvarm=array[1..50] of tvar; {таблица массив переменных}
{ID(['a'..'z'],['A'..'Z'],['А'..'Я'],['а'..'я']);}
tpznach=^tznach;
tznach=record
             p:integer;
             f:boolean;
end;
tpnode=^tnode;
tnode=record
            next:tpnode; {след звено}
            case typ:ident of
            cmif: (
            then_,else_:tpnode; {цепочки операторов}
            op1,op2:tpznach;{два из условия}
            operation:ident;{операция в условии}
            );
            cmfor: (
            fori:integer; {счетчик цикла}
            body:tpnode; {хотя так то можно}
            add:integer;
            nz,kz:tpznach; {начальное конечное значение}
            );
end;
const maxlex=25;
      mainlex:array[ident] of str_15=('программа','если','тогда',
      'иначе','конец_если','начало',
      'конец','для','до','целый',';',':',',','влево','вправо','вверх',
      'вниз','=','','<','>','^=','<=','>=','');
var f:text;
    varn:tvarm;
    ch:ident;
    lex:string;
    pnode,last:tpnode;
    varname:array[1..100] of string;
    numbvar:integer;
    st:string;
    lexnum,code:integer;
procedure readprog;{все равно потом менять}
begin
     assign(f,'cminput.txt');
     reset(f);
end;
procedure error(s:string);
begin
writeln(s);
halt(1);
end;
function getlex:ident;
var i,code:integer;
    ii:ident;
begin
    { st:='';}
     while st='' do
     readln(f,st);
     i:=1;
     while st[i]=' ' do
           inc(i);
     delete(st,1,i-1);
     i:=1;
     case st[1] of
     '<','>': begin
                   if st[2] in ['=','^'] {отрицание ^}
                   then i:=2
                   else i:=1;
                   lex:=copy(st,1,i);
                   delete(st,1,i);
              end;
     ':',';',',','=': begin
                      lex:=copy(st,1,1);
                      delete(st,1,1);
                       ii:=cmprog;
                       i:=1;
                       while (mainlex[ii]<>lex) and (i<maxlex) do
                       begin
                       inc(ii);
                       inc(i);
                       end;
                       getlex:=ii;
                     end;
     '0'..'9':begin
                   while (st[i] in ['0'..'9','.']) do
                         inc(i);
                   lex:=copy(st,1,i-1);
                   val(lex,lexnum,code); {непойми что}
                   delete(st,1,i-1);
                   getlex:=cmnumber;
                   exit;
              end;
     else begin
               if st[1] in  (['a'..'z','A'..'Z','А'..'Я','а'..'я'])
               then begin
               while st[i] in  (['a'..'z','A'..'Z','А'..'Я','а'..'я','_'])  do
                  inc(i); {букавки}
               lex:=copy(st,1,i-1);
               delete(st,1,i-1);
               end
               else begin error('Ну и что это за символ'+st[1]);
               exit;
          end;
     end;
     ii:=cmprog;
     i:=1;
     while (mainlex[ii]<>lex) and (i<maxlex) do
     begin
           inc(ii);
           inc(i);
     end;
     getlex:=ii;   {st превратить в маленькие буквы}
end;
end;
procedure progr;
begin
     if ch<>cmprog
     then error('Требуется слово программа')
     else begin
          ch:=getlex;
          if (ch<>cmident)
          then error('Требуется имя')
          else begin
               ch:=getlex;
               if ch<>cmtz then error('Требуется запятая');
               ch:=getlex;
          end;
     end;
end;
procedure razdelvar;
var numbv,i:integer;
begin
     numbv:=0;
     repeat
           repeat
                 if ch=cmident
                 then begin
                      inc(numbv);
                      varname[numbv]:=lex; {массив название переменных}
                 end;
                 ch:=getlex;
                 if not(ch in [cmtt,cmzp])
                 then error('Требуется :')
                 else begin
                      if ch=cmzp then ch:=getlex;
                 end;
           until ch=cmtt;
     ch:=getlex;
     if not(ch in[cmint]) {нет типа}
     then error('Треубется указать тип переменной')
     else begin
          for i:=1 to numbv do
          begin
               inc(numbvar);
               varn[numbvar].name:=varname[i];
               varn[numbvar].type_:=ch;       {varn-таблица переменных}
               varn[numbvar].znach:=0;
          end;
          numbv:=0;
     end;
     ch:=getlex;
     if (ch<>cmtz) then error('Требуется ;')
     else ch:=getlex;
     until ch=cmbegin;
end;
function newelem(inp:ident):tpnode;
var cur:tpnode;
begin
     case inp of
     cmup,cmleft,cmright,cmdown: begin new(cur); cur^.typ:=inp;
     end;
     {хитрим тут угу}
     end;
     newelem:=cur;
end;
{новое звено указаного типа}
procedure addelem(var last:tpnode; ne:tpnode);
begin
     last^.next:=ne;
     last:=ne;
end;
procedure operator(var last:tpnode); forward;
procedure simoperator(var last:tpnode); forward;
function findper:integer;
var i:integer;
begin
     for i:=1 to numbvar do
     begin
          if (varn[i].name=lex)
          then begin
               findper:=i;
               exit;
          end;
     end;
end;
procedure uslovie(var last:tpnode);
begin
     ch:=getlex;
     if (ch=cmnumber)
     then
     begin
     last^.op1^.f:=true;
     last^.op1^.p:=lexnum;
     end
     else begin
          last^.op1^.f:=false;
          last^.op1^.p:=findper;
     end;
     ch:=getlex;
     last^.operation:=ch;
     ch:=getlex;
     if (ch=cmnumber)
     then
     begin
     last^.op2^.f:=true;
     last^.op2^.p:=lexnum;
     end
     else begin
          last^.op2^.f:=false;
          last^.op2^.p:=findper;
     end;
end;
procedure operif(var last:tpnode);
var pp:tpnode;
begin
     addelem(last,newelem(cmif));
     uslovie(last);
     ch:=getlex;
     if ch<>cmthen
     then error('Требуется тогда');
     ch:=getlex; new(last^.then_);
     pp:=last^.then_;
     if (ch=cmbegin)
     then operator(pp)
     else simoperator(pp);
     ch:=getlex;
     if (ch=cmelse)
     then begin
     ch:=getlex; new(last^.else_);
     pp:=last^.else_;
     if (ch=cmbegin) then operator(pp) else simoperator(pp);
     ch:=getlex;
     end;
     if (ch<>Cmendif) then error('Требуется конец');
     ch:=getlex;
end;
procedure prisvoit;
var i:integer;
begin
     for i:=1 to numbvar do
     begin
          if (varn[i].name=lex)
          then begin
               ch:=getlex;
               varn[i].znach:=lexnum;
               exit;
          end;
     end;
     error('Нет такой переменной');
end;
procedure usloviefor(var last:tpnode);
begin
     ch:=getlex;
     if (ch=cmnumber)
     then begin
          last^.nz^.f:=true;
          last^.nz^.p:=lexnum;
     end
     else begin
          last^.nz^.f:=false;
          last^.nz^.p:=findper;
          ch:=getlex;
          if (ch<>cmequ) error('Требуется =');
          ch:=getlex; {берем число}
          prisvoit;
     end;
     ch:=getlex;
     if (ch<>cmto) error('Требуется до');
     ch:=getlex;
     if (ch=cmnumber)
     begin
          last^.kz^.f:=true;
          last^.kz^.p:=lexnum;
     end
     else begin
          last^.kz^.f:=true;
          last^.kz^.p:=findper;
     end;
end;
procedure operfor(var last:tpnode);
var pp:tpnode;
begin
     addelem(last,newelem(cmif));
     usloviefor(last);
     ch:=getlex;
     new(last^.body);
     pp:=last^.body;
     if (ch=cmbegin) operator(pp)
     else simoperator(pp);
     ch:=getlex;
end;
procedure operator(var last:tpnode);
begin
     repeat
           ch:=getlex;
           if (ch=cmend) then break;
           case ch of
           cmif:operif(last);
           cmleft,cmright,cmup,cmdown:
           cmfor:operfor(last);
           begin
                ch:=getlex;
           end;
           end; {тупо опеараторы нет тупых операторов}
           if (ch<>cmtz)
           then error('Требуется ;');
           ch:=getlex;
     until ch=cmend;
end;
procedure simoperator(var last:tpnode);
begin
           ch:=getlex;
           case ch of
           cmif:operif(last);
           end;
           if (ch<>cmtz)
           then error('Требуется ;');
end;
procedure main;
begin
     last:=pnode;
     numbvar:=0;
     readprog;
     ch:=getlex;
     progr;
     if ch=cmident
     then razdelvar;
     if ch=cmbegin
     then operator(last); {программа за сегодня я доложен сделать цикл }
     error('Ну все норм');
     {writeln('Синтаксических ошибок не обнаружено');}
end;
begin
     main;
end.