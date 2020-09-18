uses vesa,keyboard,crt,objects;
type pobject=^tobject;
     tpoint=record
     case target:boolen of
     true: (tp:pobject);
     false: (tx,ty:integer);
	 end;
tObject=record {ОБЪЕКТ}
	Next: pObject; {Указатель на следующий объект}
	Owner: pGroup; {Указатель на структуру <группа>, которая управляет танком}
	Type_: byte; {Тип объекта}
	X,y: integer; {зональные координаты объекта}
	OldX,OldY: array[0..1] of integer; {координаты объекта на каждой странице}
	Energy: integer; {энергия (жизнь)}
	Dx,dy: integer; {вектор перемещения}
	Vect: integer; {вектор направления, для вывода на экран}
	Offs: integer; {фаза смещения между зонами}
	Action: word; {свойства объекта: движется, стреляет и т.д.}
	DelM,DelS:byte; {Задержка перед перемещением, стрельбой и т.д.}
	Sost: byte; {состояние автомата управления объектом}
	AttackObj:pObject; {атакуемый объект}
	Defender: pGroup; {указатель на защитников}
	MainTarget: tPoint; {главная цель: true=объект; false=координаты зоны}
End;
{флага объектов}
const maxsize=4; {объект:}
	fMove=1; {движется}
	fFire=2; {стреляет}
	fPatrul=4; {патрулирует}
	fTarget=8; {задана цель}
	fSeek=16; {ищет врага}
	fFighter=32; {нападает на врага (истребитель)}
	fGuard=64; {страж}
	fSelect=128; {выделен пользователем}
	fDefender=256; {защитник}
	fFree=512; {свободен}
	fMosquito=1024; {свободный охотник}
	fDefend=2048; {под охраной}
	fSelectTarget=4096; {цель уже задана}
{команды}
	cmHelpMe=1; {Помоги мне!}
	cmAllAttack=2; {Все в атаку}
	cmAttack=4; {атаковать указанного врага}
	cmPatrul=8; { патрулировать от текущей позиции до указанной}
	cmDefend=16; {защищать указанный объект}
	cmAllReturn=32; {Всем вернуться к выполнению заданий}
	cmMove=64; {объекту переместиться в указанные координаты}
	cmShow=128; {нарисоваться}
	cmSeek =256; {искать врага}
	cmDead=512; {объект погиб}
	cmFire=1024; {стрелять}
	cmThink=2048; {искусственный интеллект объектного уровня}
	cmYouUnderFire=4096; {под огнем противника}
var f:file;
    i,page:byte;
    pic:array[1..maxsize] of pointer;
begin
     {load}
     initall(m1024x768);
     assign(f,'allspr.dat');
     reset(f,1);
     for i:=1 to maxsize do
     pic[i]:=loadspr1(f);
     {----- end load-----}
     page:=0;
     repeat
           setvisualpage(page);
           page:=1-page;
           waitvbl;
           setactivepage(page);
     until keypressed;
     doneall;
end.