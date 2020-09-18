type
ident=(cmprog,cmif,cmthen,cmelse,cmendif,cmbegin,cmend,cmfor,cmto,cmint,
cmtz,cmtt,cmzp,cmleft,cmright,cmup,cmdown,cmequ,
cmnumber,cmless,cmmore,cmnotequ,cmlesseq,cmmoreeq,cmident);
str_15=string[15];
     tvar_name=array[1..50] of str_15;
     tvar=record
                name:str_15;
                znach:integer; {�� ������� double}
                type_:ident;
     end;
tvarm=array[1..50] of tvar; {⠡��� ���ᨢ ��६�����}
{ID(['a'..'z'],['A'..'Z'],['�'..'�'],['�'..'�']);}
tpznach=^tznach;
tznach=record
             p:integer;
             f:boolean;
end;
tpnode=^tnode;
tnode=record
            next:tpnode; {᫥� �����}
            case typ:ident of
            cmif: (
            then_,else_:tpnode; {楯�窨 �����஢}
            op1,op2:tpznach;{��� �� �᫮���}
            operation:ident;{������ � �᫮���}
            );
            cmfor: (
            fori:integer; {���稪 横��}
            body:tpnode;
            nz,kz:tpznach;
            );
end;
const maxlex=25;
      mainlex:array[ident] of str_15=('�ணࠬ��','�᫨','⮣��',
      '����','�����_�᫨','��砫�',
      '�����','���','��','楫�',';',':',',','�����','��ࠢ�','�����',
      '����','=','','<','>','^=','<=','>=','');
var f:text;
    varn:tvarm;
    ch:ident;
    lex:string;
    pnode,last:tpnode;
    varname:array[1..100] of string;
    numbvar:integer;
    st:string;
procedure readprog;{�� ࠢ�� ��⮬ ������}
begin
     assign(f,'cminput.txt');
     reset(f);
end;
procedure error(s:string);
begin
writeln(s);
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
                   if st[2] in ['=','^'] {���栭�� ^}
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
                {   val(lex,lexnum,code);} {������� ��}
                   getlex:=cmnumber;
                   exit;
              end;
     else begin
               if st[1] in  (['a'..'z','A'..'Z','�'..'�','�'..'�'])
               then begin
               while st[i] in  (['a'..'z','A'..'Z','�'..'�','�'..'�'])  do
                  inc(i); {�㪠���}
               lex:=copy(st,1,i-1);
               delete(st,1,i-1);
               end
               else begin error('�� � �� �� �� ᨬ���'+st[1]);
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
     getlex:=ii;   {st �ॢ���� � �����쪨� �㪢�}
end;
end;
procedure progr;
begin
     if ch<>cmprog
     then error('�ॡ���� ᫮�� �ணࠬ��')
     else begin
          ch:=getlex;
          if (ch<>cmident)
          then error('�ॡ���� ���')
          else begin
               ch:=getlex;
               if ch<>cmtz then error('�ॡ���� ������');
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
                      varname[numbv]:=lex; {���ᨢ �������� ��६�����}
                 end;
                 ch:=getlex;
                 if not(ch in [cmtt,cmzp])
                 then error('�ॡ���� :')
                 else begin
                      if ch=cmzp then ch:=getlex;
                 end;
           until ch=cmtt;
     ch:=getlex;
     if not(ch in[cmint]) {��� ⨯�}
     then error('��㡥��� 㪠���� ⨯ ��६�����')
     else begin
          for i:=1 to numbv do
          begin
               inc(numbvar);
               varn[numbvar].name:=varname[i];
               varn[numbvar].type_:=ch;       {varn-⠡��� ��६�����}
               varn[numbvar].znach:=0;
          end;
          numbv:=0;
     end;
     ch:=getlex;
     if (ch<>cmtz) then error('�ॡ���� ;')
     else ch:=getlex;
     until ch=cmbegin;
end;
function newelem(inp:ident):tpnode;
var cur:tpnode;
begin
     case inp of
     cmup,cmleft,cmright,cmdown: begin new(cur); cur^.typ:=inp;
     end;
     {��ਬ ��� ��}
     end;
     newelem:=cur;
end;
{����� ����� 㪠������ ⨯�}
procedure addelem(var last:tpnode; ne:tpnode);
begin
     last^.next:=ne;
     last:=ne;
end;
procedure operator(var last:tpnode); forward;
procedure simoperator(var last:tpnode); forward;
procedure operif(var last:tpnode);
var pp:tpnode;
begin
     addelem(last,newelem(cmif));
    { uslovie(last); {��}
     ch:=getlex;
     if ch<>cmthen
     then error('�ॡ���� ⮣��');
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
     if (ch<>Cmendif) then error('�ॡ���� �����_�᫨');
     ch:=getlex;
end;
procedure operator(var last:tpnode);
begin
     repeat
           ch:=getlex;
           if (ch=cmend) then break;
           case ch of
           cmif:operif(last);
           end; {�㯮 ��������}
           if (ch<>cmtz)
           then error('�ॡ���� ;');
     until ch=cmend;
end;
procedure simoperator(var last:tpnode);
begin
           ch:=getlex;
           case ch of
           cmif:operif(last);
           end;
           if (ch<>cmtz)
           then error('�ॡ���� ;');
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
     then operator(last); {�ணࠬ�� �� ᥣ���� � ������� ᤥ���� 横� }
     {writeln('���⠪��᪨� �訡�� �� �����㦥��');}
end;
begin
     main;
end.
{�����稫 �� 33 ᫠��� (��� �⫠���)}