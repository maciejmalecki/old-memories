{**************************************************************************}
{*     v256 - 320/200/256 VGA sprite v1.0                                 *}
{*     Maciek Malecki 1996                                                *}
{**************************************************************************}
{ start 1996-06-11 }
{$I-}
Unit V256;

interface

Type
   IDType           = Array[1..3] of Char;
   CustomType       = Procedure(FileName:String;var Bufor);

Const
   MinReserved      = 490;
   WindowXSize:word = 320;
   WindowYSize:word = 200;
   MaxSprites       = 299;{ Sprite'y 490..499 sa zarezerwowane, jesli
                            uzywasz ktoregos z modulow V256... }
   RealBackColor:Byte = 1;
   MaxLoad          = 999;
   MaxFrames        = 16;
   MaxAnimation     = 255;
   MaxChar          = 255;
   MaxCharWidth     = 16;
   MaxCharHeight    = 16;

   MonoFont         = 0;
   ColorFont        = 1;

   DefaultFontCol   = 15;
   DefaultFontBack  = 0;
   DefaultFontTranspose = TRUE;

   TileXDim         = 16;
   TileYDim         = 16;
   TileSize         = TileXDim*TileYDim;
   TileWSize        = TileSize div 2;
   Page0: pointer   = PTR($A000,$0000);
   PageSize         = 64000;
   PageWSize        = 32000;
   PaletteSize      = 3*256;

   erNoError        = 0;
   erNotAvailable   = 9;
   erIOError        = 10;
   erIONoFile       = 11;
   erIOBadFormat    = 12;
   erNoSprite       = 30;
   erOutOfMemory    = 40;

   FastDraw         = 0;
   NormalDraw       = 1;

   PosInSequence    = 31;
   Drawing          = 32;
   Animat           = 64;

   PicID: IDType    = ('P','I','C');
   SprID: IDType    = ('S','P','R');
   PalID: IDType    = ('P','A','L');
   FntID: IDType    = ('F','N','T');
   FonID: IDType    = ('F','O','N');

   Unknown          = 0;
   Custom           = 0;
   PicFile          = 1;
   SprFile          = 2;
   PalFile          = 3;
   LibFile          = 4;
   FntFile          = 5;
   FonFile          = 6;

   SpriteOff        = 65535;

   LoopAnim         = 1;
   PeriodAnim       = 2;

   FontMask:Array[0..15] of Word =
       ($8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,8,4,2,1);

Type
   Sequence    = Array[0..MaxFrames] of Word;

   PalItem     = Record
                   Red,Green,Blue:Byte
                 End;
   TPalette    = Array[0..255] of PalItem;
   PPalette    = ^TPalette;

   TFontHeader = record
                   ID            : IDType;
                   FontType,
                   Width,
                   Height,
                   First,
                   Last          : Byte;
                   FontCol,
                   FontBack      : Byte;
                   TransposeFont : Boolean;
                   Reserved      : Array[1..8] of Byte;
                 end;
   TFontData   = Array[0..MaxChar] of Pointer;
Var
   SpriteX       : Array[0..MaxSprites] of Word;       { x coord.   }
   SpriteY       : Array[0..MaxSprites] of Word;       { y coord.   }
   SpriteNum     : Array[0..MaxSprites] of Word;       { act. shape }
   SpriteInfo    : Array[0..MaxSprites,0..1] of Byte;
   SpriteSlot    : Array[0..MaxLoad] of Pointer;
   SpriteSize    : Array[0..MaxLoad] of Word;

   FontInfo      : TFontHeader;
   FontData      : TFontData;

   Animation     : Array[0..MaxAnimation] of Sequence;
   Tiles         : Array[0..255] of Pointer;
   XMinScroll,
   YMinScroll,
   XMaxScroll,
   YMaxScroll      : Word;
   TileXMax,
   TileXMin,
   TileYMax,
   TileYMin,
   SpriteXMax,
   SpriteXMin,
   SpriteYMax,
   SpriteYMin      : Word;
   TileVWidth,
   TileVHeight,
   SpritevWidth,
   Spritevheight   : word;
   TileData        : Pointer;
   TileDataSize    : Word;
   CustomLoader    : CustomType;
   V256Inited      : Boolean;
   LastMode        : Byte;
   Page1,Page2     : Pointer;
   ActivePage      : Pointer;
   v256ErrorCode   : Byte;
   Background      : Pointer;
   Invisible       : Pointer;
   TilePage        : Pointer;
   ScrollMode,
   TransposeScroll : Boolean;
   StartVirtualX   : word;
   StartVirtualY   : word;
   OldVirtualX,
   OldVirtualY     : word;

Procedure InitV256;
Procedure DoneV256;
Function  GetError:Byte;

{ Ustawienie strony aktywnej (Page - adres strony, Page0 - obraz monitora
                              Page1, Page2 - strony wirtualne}
Procedure SetActive(Page:pointer);

Function  RoundTo16(v:Word):Word;
Procedure SetScrolledArea(XMin,YMin,XMax,YMax:Word);
Procedure InitScrollEngine;
Procedure DoneScrollEngine;
Procedure SetTile(X,Y:Word;Tile:Byte);
Function  GetTile(X,Y:Word):Byte;

{ Skopiowanie zawartosci strony Source do Dest. Page0 - obraz monitora
                                Page1, Page2 - stony wirtualne}
Procedure CopyPage(Source,Dest:pointer);

{ Wymazanie zawartosci strony Page, Page0... jak wyzej}
Procedure ClearPage(Page:pointer);

{ Wymazanie i wypelnienie kolorem Col strony Page}
Procedure FillPage(Page:pointer;Col:Byte);

{ Rysowanie wypelnionego prostokata na stronie ustawionej przez SetActive }
Procedure FillRec(X1,Y1,X2,Y2:Word;Col:Byte);

Procedure PutPixel(X,Y:Word;Col:Byte);
Function  GetPixel(X,Y:Word):Byte;

procedure line(x1,y1,x2,y2,color:integer);
Procedure Rec(X1,Y1,X2,Y2:Word;Color:Byte);


Procedure GetImage(X1,Y1,X2,Y2:Word;var Bufor);

{wyswietla obraz, tr oznacza 0 - CopyPut, 1 - kolor 0 przeswituje}
Procedure PutImage(X,Y:Integer;var Bufor;tr:byte);

{automatycznie usuwa obrazek powstaly np. przez GetImage}
Procedure DisposeBitmap(var Bitmap:Pointer);

Procedure PutTile(X,Y:Integer;Bufor:Pointer;Tr:Byte);
Procedure PutTileBord(X,Y:Integer;Bufor:Pointer;Tr:Byte);
Procedure RefreshScrolledArea(Tr:Byte);

{wczytuje obrazek w formacie .pic}
Procedure LoadPic(FileName:String;var Bufor);

{wczytuje sprite'a w formacie .spr}
Procedure LoadSpr(FileName:String;var Bufor);

{lepsze wczytywanie (od razu sprite jest wczytywany pod odpowiedni numer}
Function  LoadSprite(FileName:String;SprNum:Word):Word;

Procedure LoadTil(FileName:String;var Bufor);
Function  LoadTile(FileName:String;TilNum:Byte):Byte;

{usuwa sprite'a}
Procedure KillSprite(SprNum:Word);

{ustawienie sprite'a: Num numer sprite'a, X,Y - wspolrzedne wirtualne,
 SprNum numer obrazka (ten pod ktory wczyta np. LoadSprite,
 Anim rodzaj animacji LoopAnim,PeriodAnim; Info : jesli ma przeswitywac,
 napisz Drawing, jesli nie - 0}
Procedure SetSprite(Num:Word;X,Y:Integer;SprNum:Word;Info,Anim:Byte);

Procedure LoadData(FileName:String;var Bufor);
Function  ID2FileType(ID:IDType):Byte;
Procedure FileInfo(FileName:String;var FileType:Byte;var DataSize:Word);
Function  GetFileSize(FileName:String):Word;
Procedure Glupol(FileName:String;var Bufor);

Procedure WaitRetrace;
Procedure UpdateScreen;
Procedure Animate;

Procedure SetPalette(Pal:Pointer);
Procedure GetPalette(Pal:Pointer);
Procedure WritePalette(Pal:Pointer;_Start,Count:Byte);
Procedure ReadPalette(Pal:Pointer;_Start,Count:Byte);

Procedure LoadFON(FileName:String;var HD:TFontHeader;var FD:TFontData);
Procedure LoadFNT(FileName:String;var HD:TFontHeader;var FD:TFontData);
Procedure LoadFont(FileName:String);
Procedure DisposeFont;
Function  GetTextHeight:Word;
Function  GetTextWidth(Tx:String):Word;
Procedure MakeFontBitmap(Tx:String;var Bufor:Pointer);
Procedure OutTextXY(X,Y:Integer;Tx:String);
Procedure CreateButton(Tx:String;var Normal,Pressed:Pointer);
Procedure SwitchFont(var HD:TFontHeader;var FD:TFontData);

implementation

uses MMisc;

Procedure InitV256;
Var X:Word;
Begin
  If V256Inited then Exit;
  V256Inited:=TRUE;
  GetMem(Page1,PageSize);
  GetMem(Page2,PageSize);
  ClearPage(Page0);
  ClearPage(Page1);
  ClearPage(Page2);
  ActivePage:=Page0;
  Background:=Page2;
  Invisible:=Page1;
  TilePage:=Page2;
  V256ErrorCode:=erNoError;
  StartVirtualX:=0;
  StartVirtualY:=0;
  SpriteXMin:=0;TileXMin:=0;
  SpriteXMax:=319;TileXMax:=319;
  SpriteYMin:=0;TileYMin:=0;
  SpriteYMax:=199;TileYMax:=199;
  SpriteVWidth:=320;
  SpritevHeight:=200;
  TileVWidth:=320;
  TileVHeight:=200;
  For X:=0 To 255 do Tiles[x]:=nil;
  For X:=0 To MaxSprites Do
    Begin
      SpriteNum[X]:=SpriteOff;{ wylacz wszystkie sprite'y }
    End;
  LastMode:=mGetMode;
  mSetMode($13);
End;

Procedure DoneV256;
Begin
  if not V256Inited then Exit;
  V256Inited:=FALSE;
  mSetMode(LastMode);
  FreeMem(Page1,PageSize);
  FreeMem(Page2,PageSize);
End;

Function  GetError:Byte;
Begin
  GetError:=V256ErrorCode;
  V256ErrorCode:=erNoError;
End;

Procedure SetActive(Page:pointer);
Begin
  ActivePage:=Page;
End;

Procedure CopyPage(Source,Dest:pointer);Assembler;
{ by MaMalecki, 1996-06-11 v1.0b }
Asm
  push ds
  lds  si,Source
  les  di,Dest
  cld
  mov  cx,PageWSize
  rep  movsw
  pop  ds
End;

Procedure ClearPage(Page:pointer);Assembler;
{ by MaMalecki, 1996-06-12 v1.0b }
Asm
  les  di,Page
  mov  ax,00h
  cld
  mov  cx,PageWSize
  rep  stosw
End;

Procedure FillPage(Page:pointer;Col:Byte);Assembler;
{ by MaMalecki, 1996-06-12 v1.0b }
Asm
  les  di,Page
  mov  ah,Col
  mov  al,Col
  cld
  mov  cx,PageWSize
  rep  stosw
End;

Procedure FillRec(X1,Y1,X2,Y2:Word;Col:Byte);Assembler;
Asm
  les  di,ActivePage
  mov  ax,x2
  sub  ax,x1
  inc  ax
  mov  cx,ax
  mov  ax,Y2
  sub  ax,Y1
  inc  ax
  push ax
  mov  ax,Y1
  mov  bx,320
  mul  bx
  add  ax,X1
  add  di,ax
  mov  al,Col
  pop  dx
  cld
@DRAW:
  push di
  push cx
  rep  stosb
  pop  cx
  pop  di
  dec  dx
  jz   @L00
  add  di,320
  jmp  @DRAW
@L00:
End;

Procedure PutPixel(X,Y:Word;Col:Byte);Assembler;
Asm
  les  si,ActivePage
  mov  ax,320
  mul  y
  add  ax,x
  add  si,ax
  mov  ah,Col
  mov  es:[si],ah
End;

Function  GetPixel(X,Y:Word):Byte;Assembler;
Asm
  les  si,ActivePage
  mov  ax,320
  mul  y
  add  ax,x
  add  si,ax
  mov  ax,es:[si]
End;

Procedure LoadPic(FileName:String;var Bufor);
Var F:File;
    W,S:Word;
    X:Byte;
    T:IDType;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult<>0 Then v256ErrorCode:=erIONoFile
   else
    Begin
      If FileSize(F)<>64003 Then
        Begin
          v256ErrorCode:=erIOBadFormat;
          Close(F)
        End
         else
          Begin
            BlockRead(F,T,3);
            If T<>PicID Then
              Begin
                v256ErrorCode:=erIOBadFormat;
                Close(F);
              End
               else
                Begin
                  BlockRead(F,Bufor,64000,W);
                  If W<>64000 Then v256ErrorCode:=erIOError else v256ErrorCode:=erNOError;
                  Close(F);
                End;
          End;
    End;
End;

Procedure LoadSpr(FileName:String;var Bufor);
Var F:File;
    W:Word;
    X:Byte;
    T:IDType;
    Dim:Array[0..1] of Word;
    Size:Word;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult=0 Then
   Begin
     BlockRead(F,T,SizeOf(T),W);
     If W=SizeOf(T) Then
       Begin
         BlockRead(F,Dim,SizeOf(Dim),W);
         If W=SizeOf(Dim) Then
           Begin
             Size:=Dim[0]*Dim[1]+4;
             Seek(F,3);
             BlockRead(F,Bufor,Size,W);
             If W<>Size Then v256ErrorCode:=erIOBadFormat;
           End
            else
           v256ErrorCode:=erIOBadFormat;
       End
        else
       v256ErrorCode:=erIOBadFormat;
     Close(F);
   End
    else
   v256ErrorCode:=erIONoFile;
End;

Procedure LoadData(FileName:String;var Bufor);
Var Typ:Byte;
    Rozm:Word;
Begin
  FileInfo(FileName,Typ,Rozm);
  Case Typ Of
    PicFile:LoadPic(FileName,Bufor);
    SprFile:LoadSpr(FileName,Bufor);
    Custom:CustomLoader(FileName,Bufor);
  End;
End;

Procedure GetImage(X1,Y1,X2,Y2:Word;var Bufor);Assembler;
{ by MaMalecki, 1996-06-13, v1.0b  (propably O.K.) }
Asm
  push ds
  les  di,[dword ptr Bufor]
  lds  si,ActivePage
  { offset }
  mov  ax,Y1
  mov  bx,320
  mul  bx
  add  ax,X1
  add  si,ax
  { obliczanie wymiarow obrazka }
  mov  ax,X2
  sub  ax,X1
  inc  ax
  mov  es:[di],ax                   { szerokosc }
  mov  cx,ax
  mov  ax,Y2
  sub  ax,Y1
  inc  ax
  mov  es:[di+2],ax                 { wysokosc }
  mov  dx,ax
  { dalej }
  add  di,4
@L00:
  push si
  push cx
  rep  movsb
  pop  cx
  pop  si
  dec  dx
  jz  @L01
  add  si,320
  jmp  @L00
@L01:
  pop  ds
End;

Procedure PutImage(X,Y:Integer;var Bufor;tr:byte);Assembler;
{ by MacMalecki, 1996.06.19, v1.0 }
Asm
  push ds
  les  di,ActivePage
  lds  si,[dword ptr Bufor]
  { rozmiary obrazka }
  mov  cx,[si]                   {*cx <- szerokosc    }
  mov  dx,[si+2]                 {*dx <- wysokosc     }
  mov  ax,Y                      {*jesli caly sprite  }
  add  ax,dx                     { jest ponad ekranem }
  cmp  ax,0                      {                    }
  jle  @L00                      { to koniec          }
  mov  ax,Y                      {*jesli caly sprite  }
  cmp  ax,200                    { jest ponizej ekra- }
  jge  @L00                      { nu, to koniec      }
  mov  ax,x                      {*jesli caly sprite  }
  add  ax,cx                     { na lewo od ekranu, }
  cmp  ax,0                      { to koniec          }
  jle  @L00
  mov  ax,x                      {*jesli caly sprite  }
  cmp  ax,320                    { na prawo od ekranu,}
  jge  @L00                      { to koniec          }
  push cx
  add  si,4                      {*si na pocz. danych }
  mov  ax,Y                      {*gdy Y<0 to czescio-}
  cmp  ax,0                      { wo schowany        }
  jl   @Y_OD_ZERA
                                 {*gdy Y+dx>199 to    }
  add  ax,dx                     { czesciowo schowany.}
  cmp  ax,199
  jg   @Y_DO_K
  {----------------}
  push dx                        {*normalny offset "Y"}
  mov  ax,320
  mov  bx,Y
  mul  bx
  add  di,ax
  pop  dx
  {----------------}
@DALEJ2:
  mov  ax,X                      {*gdy X<0 to czesciow}
  cmp  ax,0
  jl   @X_OD_ZERA
  add  ax,cx                     {*gdy X+cx>319 to... }
  cmp  ax,319
  jg   @X_DO_K
  {----------------}
  add  di,x                      {*normalny offset "X"}
  jmp  @DRAW
@DALEJ1:                         {*gdy Y+dx>199       }
  mov  ax,Y
  add  ax,dx
  cmp  ax,199
  jg   @Y_DO_K
  jmp  @DALEJ2
@DALEJ3:                         {*gdy X+cx>319       }
  mov  ax,X
  add  ax,cx
  cmp  ax,319
  jg   @X_DO_K
  jmp  @DRAW
@DALEJ11:                        {*gdy Y+dx>199 i Y<0 }
  cmp  dx,199
  jg   @Y_DO_K_2
  jmp  @DALEJ2
@DALEJ13:                        {*gdy X+cx>319 i X<0 }
  cmp  cx,319
  jg   @X_DO_K_2
  jmp  @DRAW
@Y_OD_ZERA:
  push dx
  add  dx,ax
  pop  ax
  sub  ax,dx
  push dx
  mul  cx
  add  si,ax
  pop  dx
  jmp  @DALEJ11
@Y_DO_K:
  mov  ax,200
  sub  ax,y
  mov  dx,ax
  push dx
  mov  ax,y
  mov  bx,320
  mul  bx
  add  di,ax
  pop  dx
  jmp  @DALEJ2
@Y_DO_K_2:
  mov  dx,200
  jmp  @DALEJ2
@X_OD_ZERA:
  mov  ax,X
  push cx
  add  cx,ax
  pop  ax
  sub  ax,cx
  add  si,ax
  jmp  @DALEJ13
@X_DO_K:
  mov  ax,320
  sub  ax,x
  mov  cx,ax
  add  di,x
  jmp  @DRAW
@X_DO_K_2:
  mov  cx,320
@DRAW:
  pop  bx
  cld
  mov  ah,tr
  cmp  ah,0
  jne  @DRAW2
@DRAW1:                 {*fast drawing routine }
  push si
  push di
  push cx
  rep  movsb
  pop  cx
  pop  di
  pop  si
  add  si,bx
  dec  dx
  jz   @L00
  add  di,320
  jmp  @DRAW1
@DRAW2:                 {*normal drawing routine }
  push si
  push di
  push cx
@LO1:
  mov  ah,ds:[si]
  or   ah,ah            {*dla koloru zero nie rysowac }
  jz   @G02
  movsb
  jmp  @G01
@G02:
  inc  si
  inc  di
@G01:
  loop @LO1
  pop  cx
  pop  di
  pop  si
  add  si,bx
  dec  dx
  jz   @L00
  add  di,320
  jmp  @DRAW2
@L00:
  pop  ds
End;

Function  ID2FileType(ID:IDType):Byte;
Var T:Byte;
Begin
  T:=Unknown;
  If ID=PicID Then T:=PicFile;
  If ID=SprID Then T:=SprFile;
  If ID=PalID Then T:=PalFile;
  If ID=FntID Then T:=FntFile;
  If ID=FonID Then T:=FonFile;
  ID2FileType:=T;
End;

Procedure FileInfo(FileName:String;var FileType:Byte;var DataSize:Word);
Var
   F:File;
   ID:IDType;
   W,XS,YS:Word;
   X:Byte;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult=0 Then
    Begin
      BlockRead(F,ID,SizeOf(ID),W);
      If W=SizeOf(ID) Then
        Begin
          FileType:=ID2FileType(ID);
          Case FileType of
            PicFile:DataSize:=64000;
            FntFile,FonFile:DataSize:=0;
            SprFile:
              Begin
                BlockRead(F,XS,2,W);
                If W=2 Then
                 Begin
                  BlockRead(F,YS,2,W);
                  If W=2 Then DataSize:=(XS+1)*(YS+1) else v256ErrorCode:=erIOBadFormat
                 End
                  else
                 v256ErrorCode:=erIOBadFormat;
              End;
            PalFile:v256ErrorCode:=erNotAvailable;{not implemented}
            LibFile:v256ErrorCode:=erNotAvailable;{not implemented}
            Unknown:
              Begin
                Seek(F,0);
                BlockRead(F,XS,2,W);
                If W=2 Then
                 Begin
                  BlockRead(F,YS,2,W);
                  If W=2 Then DataSize:=(XS+1)*(YS+1) else v256ErrorCode:=erIOBadFormat
                 End
                  else
                 v256ErrorCode:=erIOBadFormat;
              End;
          End;
        End
         else
        v256ErrorCode:=erIOBadFormat;
      Close(F);
    End
     else
    v256ErrorCode:=erIONoFile;
End;

Function  GetFileSize(FileName:String):Word;
Var Typ:Byte;
    Rozm:Word;
Begin
  FileInfo(FileName,Typ,Rozm);
  GetFileSize:=Rozm;
End;

Procedure Glupol(FileName:String;var Bufor);
Begin
  v256ErrorCode:=erNotAvailable;
End;

Procedure Animate;
Var X:Word;
    Draw:Byte;
    B:Byte;
    An:Byte;
    Tr:Byte;
Begin
 { If ScrollMode Then
  Begin }
    {
    If (OldVirtualX<>StartVirtualX) or (OldVirtualY<>StartVirtualY) then
      RefreshScrolledArea(FastDraw);
        }
   { Asm
      mov ax,OldVirtualX          }      {aktualizacja obszaru scrolled}
{      cmp ax,StartVirtualX         }     {gdy zmieniono StartVirtual... }
 {     jne @L01
      mov ax,OldVirtualY
      cmp ax,StartVirtualY
      jne @L01
      jmp @E01
      @L01:
      Mov ax,FastDraw
      Push ax
      Call RefreshScrolledArea
      @E01:
    End;
    CopyPage(TilePage,Invisible);
    OldVirtualX:=StartVirtualX;
    OldVirtualY:=StartVirtualY;
  End
    else}
  CopyPage(Background,Invisible);
  ActivePage:=Invisible;
  For X:=0 To MaxSprites Do
   If SpriteNum[X]<>SpriteOff Then
     Begin
{       Draw:=NormalDraw;}
       Draw:=(SpriteInfo[X,0] and Drawing) shr 5;
       If (SpriteInfo[X,0] and Animat)=Animat Then
         Begin
           B:=SpriteInfo[X,0] and PosInSequence;
           Inc(B);
           An:=SpriteInfo[X,1];
           If B>Animation[An][0] Then B:=1;
           B:=B and PosInSequence;
           SpriteInfo[X,0]:=SpriteInfo[X,0] and (Animat+Drawing);
           SpriteInfo[X,0]:=SpriteInfo[X,0] or B;
           SpriteNum[X]:=Animation[An][B];
         End;
       PutImage(SpriteX[X]-StartVirtualX,SpriteY[X]-StartVirtualY,SpriteSlot[SpriteNum[X]]^,Draw);
     End;
End;

procedure WaitRetrace;Assembler;
Asm
   mov dx,$03DA
@L01:
   in  al,dx
   test al,$08
   jz @L01
@L02:
   in  al,dx
   test al,$08
   jnz @L02
End;

procedure UpdateScreen;Assembler;
Asm
  mov dx,$03DA                          {wait retrace}
@L01:
  in  al,dx
  test al,$08
  jz @L01
@L02:
  in  al,dx
  test al,$08
  jnz @L02
  les  di,Page0                         {update screen}
  push ds
  lds  si,Invisible
  cld
  mov  cx,PageWSize
  rep  movsw
  pop  ds
End;


Function  LoadSprite(FileName:String;SprNum:Word):Word;
Begin
  v256ErrorCode:=0;
  SpriteSize[SprNum]:=GetFileSize(FileName)+4;
  If v256ErrorCode <> erNoError Then Exit;
  if MaxAvail<SpriteSize[SprNum] then
    Begin
      v256ErrorCode:=erOutOfMemory;
      Exit;
    End;
  GetMem(SpriteSlot[SprNum],SpriteSize[SprNum]);
  LoadSpr(FileName,SpriteSlot[SprNum]^);
  If v256ErrorCode<> erNoError Then
  Begin
    KillSprite(SprNum);
    Exit;
  End;
End;

Procedure KillSprite(SprNum:Word);
Begin
  if SpriteSlot[SprNum]<>nil Then
    Begin
      FreeMem(SpriteSlot[SprNum],SpriteSize[SprNum]);
      SpriteSlot[SprNum]:=nil;
    End;
End;

Procedure SetSprite(Num:Word;X,Y:Integer;SprNum:Word;Info,Anim:Byte);
Begin
  SpriteNum[Num]:=SprNum;
  SpriteX[Num]:=X;
  SpriteY[Num]:=Y;
  SpriteInfo[Num,0]:=Info;
  SpriteInfo[Num,1]:=Anim;
End;

Procedure LoadTil(FileName:String;var Bufor);
Var
   F:File;
   W:Word;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult<>0 Then
    Begin
      v256ErrorCode:=erIONoFile;
      Exit;
    End;
  If FileSize(F)<16 Then
    Begin
      v256ErrorCode:=erIOBadFormat;
      Close(F);
      Exit;
    End;
  BlockRead(F,Bufor,TileSize,W);
  Close(F);
  If TileSize<>W then
   Begin
     v256ErrorCode:=erIOError;
     Exit;
   End;
  v256ErrorCode:=erNoError;
End;

Function  LoadTile(FileName:String;TilNum:Byte):Byte;
Var
   F:File;
   Readed:Byte;
   Num,W:Word;
Begin
  Readed:=0;
  Assign(F,Filename);
  Reset(F,1);
  If IOResult<>0 Then
    Begin
      v256ErrorCode:=erIONoFile;
      LoadTile:=Readed;
      Exit;
    End;
  If FileSize(F)<16 Then
    Begin
      Close(F);
      v256ErrorCode:=erIOBadFormat;
      LoadTile:=Readed;
      Exit;
    End;
    Repeat
      Num:=Readed+TilNum;
      If Num<=255 Then
       Begin
         GetMem(Tiles[Num],TileSize);
         BlockRead(F,Tiles[Num]^,TileSize,W);
         If W<>TileSize Then
            FreeMem(Tiles[Num],TileSize)
              else
            Inc(Readed);
       End;
    Until (W<>TileSize) or (Num>255);
    Close(F);
    v256ErrorCode:=erNoError;
    LoadTile:=Readed;
End;

Procedure PutTile(X,Y:Integer;Bufor:Pointer;Tr:Byte);Assembler;
Asm
  les  di,TilePage
  push ds
  lds  si,Bufor
  mov  cx,8
  mov  ax,Y
  mov  bx,320
  mul  bx
  add  ax,X
  add  di,ax
  mov  dx,16
@LOOP:
  push cx
  push di
  rep  movsw
  pop  di
  pop  cx
  dec  dx
  jz   @EXIT
  add  di,320
  jmp  @LOOP
@EXIT:
  pop  ds
End;

Procedure PutTileBord(X,Y:Integer;Bufor:Pointer;Tr:Byte);Assembler;
{ by MacMalecki, 1996.06.19, v1.0 }
Asm
  push ds
  les  di,TilePage
  lds  si,Bufor
  { rozmiary obrazka }
  mov  cx,16                   {*cx <- szerokosc    }
  mov  dx,16                 {*dx <- wysokosc}
  mov  ax,Y                      {*jesli caly sprite  }
  add  ax,dx                     { jest ponad ekranem }
  cmp  ax,0                      {                    }
  jle  @L00                      { to koniec          }
  mov  ax,Y                      {*jesli caly sprite  }
  cmp  ax,200                    { jest ponizej ekra- }
  jge  @L00                      { nu, to koniec      }
  mov  ax,x                      {*jesli caly sprite  }
  add  ax,cx                     { na lewo od ekranu, }
  cmp  ax,0                      { to koniec          }
  jle  @L00
  mov  ax,x                      {*jesli caly sprite  }
  cmp  ax,320                    { na prawo od ekranu,}
  jge  @L00                      { to koniec          }
  push cx
  mov  ax,Y                      {*gdy Y<0 to czescio-}
  cmp  ax,0                      { wo schowany        }
  jl   @Y_OD_ZERA
                                 {*gdy Y+dx>199 to    }
  add  ax,dx                     { czesciowo schowany.}
  cmp  ax,199
  jg   @Y_DO_K
  {----------------}
  push dx                        {*normalny offset "Y"}
  mov  ax,320
  mov  bx,Y
  mul  bx
  add  di,ax
  pop  dx
  {----------------}
@DALEJ2:
  mov  ax,X                      {*gdy X<0 to czesciow}
  cmp  ax,0
  jl   @X_OD_ZERA
  add  ax,cx                     {*gdy X+cx>319 to... }
  cmp  ax,319
  jg   @X_DO_K
  {----------------}
  add  di,x                      {*normalny offset "X"}
  jmp  @DRAW
@DALEJ1:                         {*gdy Y+dx>199       }
  mov  ax,Y
  add  ax,dx
  cmp  ax,199
  jg   @Y_DO_K
  jmp  @DALEJ2
@DALEJ3:                         {*gdy X+cx>319       }
  mov  ax,X
  add  ax,cx
  cmp  ax,319
  jg   @X_DO_K
  jmp  @DRAW
@DALEJ11:                        {*gdy Y+dx>199 i Y<0 }
  cmp  dx,199
  jg   @Y_DO_K_2
  jmp  @DALEJ2
@DALEJ13:                        {*gdy X+cx>319 i X<0 }
  cmp  cx,319
  jg   @X_DO_K_2
  jmp  @DRAW
@Y_OD_ZERA:
  push dx
  add  dx,ax
  pop  ax
  sub  ax,dx
  push dx
  mul  cx
  add  si,ax
  pop  dx
  jmp  @DALEJ11
@Y_DO_K:
  mov  ax,200
  sub  ax,y
  mov  dx,ax
  push dx
  mov  ax,y
  mov  bx,320
  mul  bx
  add  di,ax
  pop  dx
  jmp  @DALEJ2
@Y_DO_K_2:
  mov  dx,200
  jmp  @DALEJ2
@X_OD_ZERA:
  mov  ax,X
  push cx
  add  cx,ax
  pop  ax
  sub  ax,cx
  add  si,ax
  jmp  @DALEJ13
@X_DO_K:
  mov  ax,320
  sub  ax,x
  mov  cx,ax
  add  di,x
  jmp  @DRAW
@X_DO_K_2:
  mov  cx,320
@DRAW:
  pop  bx
  cld
  mov  ah,tr
  or   ah,ah
  jnz  @DRAW2
@DRAW1:                 {*fast drawing routine }
  push si
  push di
  push cx
  rep  movsb
  pop  cx
  pop  di
  pop  si
  add  si,bx
  dec  dx
  jz   @L00
  add  di,320
  jmp  @DRAW1
@DRAW2:                 {*normal drawing routine }
  push si
  push di
  push cx
@LO1:
  mov  ah,ds:[si]
  or   ah,ah            {*dla koloru zero nie rysowac }
  jz   @G02
  movsb
  jmp  @G01
@G02:
  inc  si
  inc  di
@G01:
  loop @LO1
  pop  cx
  pop  di
  pop  si
  add  si,bx
  dec  dx
  jz   @L00
  add  di,320
  jmp  @DRAW2
@L00:
  pop  ds
End;


Procedure SetScrolledArea(XMin,YMin,XMax,YMax:Word);
Begin
  XMaxScroll:=RoundTo16(XMax);
  XMinScroll:=RoundTo16(XMin);
  YMaxScroll:=RoundTo16(YMax);
  YMinScroll:=RoundTo16(YMin);
End;

Procedure InitScrollEngine;
Var _Ofs:Word;
    Dum:^Byte;
Begin
  OldVirtualX:=0;
  OldVirtualY:=StartVirtualY+1;
  TileDataSize:=((XMaxScroll-XMinScroll+1){ div 16})*((YMaxScroll-YMinScroll+1){ div 16});
  GetMem(TileData,TileDataSize);
  Repeat
    _Ofs:=Ofs(TileData^);
    If _Ofs>0 Then
      Begin
        FreeMem(TileData,TileDataSize);
        New(Dum);
        GetMem(TileData,TileDataSize);
      End;
  Until _Ofs=0;
  FillChar(TileData^,TileDataSize,2);
  ScrollMode:=TRUE;
End;

Procedure DoneScrollEngine;
Begin
  FreeMem(TileData,TileDataSize);
  ScrollMode:=FALSE;
End;

Procedure SetTile(X,Y:Word;Tile:Byte);
Var
  NX,NY,S,Ofst:Word;
Begin
{  NX:=X div 16;
  NY:=Y div 16;}
  S:=XMaxScroll-YMinScroll+1;
{  S:=S div 16};
  Ofst:=Y*S+X;
  Asm
    les  di,TileData
    mov  ax,Ofst
    add  di,ax
    mov  al,Tile
    mov  es:[di],al
  End;
End;

Function  GetTile(X,Y:Word):Byte;
Var
  NX,NY,S,Ofst:Word;
Begin
{  NX:=X div 16;
  NY:=Y div 16; }
  S:=XMaxScroll-YMinScroll+1;
 { S:=S div 16;}
  Ofst:=Y*S+X;
  Asm
    les  di,TileData
    mov  ax,Ofst
    add  di,ax
    mov  al,es:[di]
    mov  @Result,al
  End
End;

Function  RoundTo16(v:Word):Word;
Begin
  RoundTo16:=(v{ div 16}){*16;}
End;

Procedure RefreshScrolledArea(Tr:Byte);
Var
   PoprawkaX,
   PoprawkaY:Integer;
   Offset:Word;
   TilesWidth,
   TilesHeight:Word;
   VisualWidth,
   VisualHeight:Byte;
   StartX,StartY:Word;
   XMin,XMax,YMin,YMax:Word;
   X,Y:Byte;
   _Seg,_Ofs:Word;
   L,R,U,D:Boolean;

Begin
  _Seg:=Seg(TileData^);
  StartX:=StartVirtualX div 16;
  StartY:=StartVirtualY div 16;
  PoprawkaX:=StartX*16-StartVirtualX;
  PoprawkaY:=StartY*16-StartVirtualY;
  XMin:=XMinScroll{ div 16};
  XMax:=XMaxScroll{ div 16};
  YMin:=YMinScroll{ div 16};
  YMax:=YMaxScroll{ div 16};
  TilesWidth:=XMax-XMin+1;
  TilesHeight:=YMax-YMin+1;
  If PoprawkaX<0 Then VisualWidth:=21 else VisualWidth:=20;
  If PoprawkaY<0 Then VisualHeight:=14 else VisualHeight:=13;
  For Y:=0 to VisualHeight-1 do
    For X:=0 to VisualWidth-1 do
      Begin
        ActivePage:=TilePage;
        Offset:=TilesWidth*(StartY+Y-YMin)+StartX+X-XMin;
        If ((StartY+Y)>=YMin) and (StartY+Y<=YMax)
        and ((StartX+X)>=XMin) and (StartX+X<=XMax) Then
        If ((PoprawkaX+X*16)<0) or ((PoprawkaX+X*16+16)>319) or
           ((PoprawkaY+Y*16)<0) or ((PoprawkaY+Y*16+16)>199) then
        PutTileBord(PoprawkaX+X*16,PoprawkaY+Y*16,Tiles[Mem[_Seg:Offset]],Tr)
        else
        PutTile(PoprawkaX+X*16,PoprawkaY+Y*16,Tiles[Mem[_Seg:Offset]],Tr)
        else {if not z tlem static}
      End;
  If StartVirtualX<XMinScroll*16 then L:=True else L:=False;
  If StartVirtualX+WindowXSize>XMaxScroll*16 then R:=True else R:=False;
  If StartVirtualY<YMinScroll*16 then U:=True else U:=False;
  If StartVirtualY+WindowYSize>YMaxScroll*16 then D:=True else D:=False;
  If L then FillRec(0,0,XMinScroll*16-StartVirtualX,WindowYSize-1,RealBackColor);
  If R then FillRec(XMaxScroll*16-StartVirtualX,0,WindowXSize-1,WindowYSize-1,RealBackColor);
  If U then FillRec(0,0,WindowXSize-1,YMinScroll*16-StartVirtualY,RealBackColor);
  If D then FillRec(0,YMaxScroll*16-StartVirtualY,WindowXSize-1,WindowYSize-1,RealBackColor);
End;

Procedure SetPalette(Pal:Pointer);Assembler;
Asm
  push ds
  mov dx,$03DA
@L01:
  in  al,dx
  test al,$08
  jz @L01
@L02:
  in  al,dx
  test al,$08
  jnz @L02
{-------------------}
  lds  si,Pal
  mov  cx,3*256
  mov  dx,$3C8
  xor  al,al
  out  dx,al
  inc  dx
  cld
@L03:
  lodsb
  out  dx,al
  loop @L03
  pop  ds
End;

Procedure GetPalette(Pal:Pointer);Assembler;
  Asm
    les  di,Pal
    mov  cx,3*256
    mov  dx,$3C7
    xor  al,al
    out  dx,al
    inc  dx
    inc  dx
    cld
  @L01:
    in   al,dx
    stosb
    loop @L01
  End;

Procedure WritePalette(Pal:Pointer;_Start,Count:Byte);Assembler;
Asm
  push ds
  mov dx,$03DA
@L01:
  in  al,dx
  test al,$08
  jz @L01
@L02:
  in  al,dx
  test al,$08
  jnz @L02
{-------------------}
  lds  si,Pal
  mov  al,Count
  mov  bl,3
  mul  bl
  mov  cx,ax
  mov  dx,$3C8
  xor  al,al
  out  dx,al
  inc  dx
  cld
@L03:
  lodsb
  out  dx,al
  loop @L03
  pop  ds
End;

Procedure ReadPalette(Pal:Pointer;_Start,Count:Byte);Assembler;
  Asm
    les  di,Pal
    mov  al,count
    mov  bl,3
    mul  bl
    mov  cx,ax
    mov  dx,$3C7
    mov  al,_Start
    out  dx,al
    inc  dx
    inc  dx
    cld
  @L01:
    in   al,dx
    stosb
    loop @L01
  End;

Procedure LoadFON(FileName:String;var HD:TFontHeader;var FD:TFontData);
Var F:File;
    W:Word;
    Size:Word;
    X:Byte;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult<>0 then Begin v256ErrorCode:=erIONoFile;exit end;
  BlockRead(F,HD,SizeOf(HD),W);
  If W<>SizeOf(HD) Then
    Begin
      Close(F);
      v256ErrorCode:=erIOBadFormat;
      Exit;
    End;
  With HD Do
    Begin
      If (FontType and ColorFont)<>ColorFont then
        If Width<=8 then Size:=Height else Size:=2*Height
      else
      Size:=Width*Height;
    End;
    For X:=HD.First to HD.Last do
      Begin
        GetMem(FD[X],Size);
        FillChar(FD[X]^,Size,0);
        BlockRead(F,FD[X]^,Size,W);
        If W<>Size Then
          Begin
            Close(F);
            V256ErrorCode:=erIOBadFormat;
            Exit;
          End;
      End;
  Close(F);

End;

Procedure LoadFNT(FileName:String;var HD:TFontHeader;var FD:TFontData);
Var F:File;
    MH:record
         _Width,
         _Height,
         _FontType:Byte;
       End;
    W:Word;
    Size:Word;
    X:Byte;
Begin
  Assign(F,FileName);
  Reset(F,1);
  If IOResult<>0 then Begin v256ErrorCode:=erIONoFile;exit end;
  Seek(F,3);
  BlockRead(F,MH,SizeOf(MH),W);
  if W<>SizeOf(MH) then
    Begin
      Close(F);
      v256ErrorCode:=erIOBadFormat;
      Exit;
    End;
  With HD do
    Begin
      ID:=FntID;
      FontType:=MH._FontType;
      Width:=MH._Width;
      Height:=MH._Height;
      First:=0;
      Last:=255;
      FontCol:=DefaultFontCol;
      FontBack:=DefaultFontBack;
      TransposeFont:=DefaultFontTranspose;
      If (FontType and ColorFont)<>ColorFont then
        If Width<=8 then Size:=Height else Size:=2*Height
      else
      Size:=Width*Height;
    End;
    For X:=0 to 255 do
      Begin
        GetMem(FD[X],Size);
        FillChar(FD[X]^,Size,0);
        BlockRead(F,FD[X]^,Size,W);
        If W<>Size Then
          Begin
            Close(F);
            V256ErrorCode:=erIOBadFormat;
            Exit;
          End;
      End;
  Close(F);
End;

Procedure LoadFont(FileName:String);
Var
    FT:Byte;
    S:Word;
Begin
  FileInfo(FileName,FT,S);
  If V256ErrorCode<>erNoError then Exit;
  case FT of
  FntFile:LoadFnt(FileName,FontInfo,FontData);
  FonFile:LoadFon(FileName,FontInfo,FontData)
  else
    Begin
      V256ErrorCode:=erIOBadFormat;
      exit;
    End;
  end;
End;

Procedure DisposeFont;
Var X:Byte;
    Size:Word;
Begin
  With FontInfo Do
    Begin
      If (FontType and ColorFont)<>ColorFont then
        If Width<=8 then Size:=Height else Size:=2*Height
      else
      Size:=Width*Height;
      For X:=First to Last Do If FontData[X]<>nil then begin FreeMem(FontData[x],size);FontData[X]:=nil;end;
      FillChar(FontInfo,SizeOf(FontInfo),0);
    End;
End;


Function  GetTextWidth(Tx:String):Word;
Begin
  With FontInfo Do
      GetTextWidth:=Width*Ord(Tx[0]);
End;


Function  GetTextHeight:Word;
Begin
  GetTextHeight:=FontInfo.Height;
End;


Procedure DisposeBitmap(var Bitmap:Pointer);
Var _Ofs,_Seg:Word;
    X,Y:Word;
Begin
  _Seg:=Seg(Bitmap^);
  _Ofs:=Ofs(Bitmap^);
  X:=MemW[_Seg:_Ofs];
  Y:=MemW[_Seg:_Ofs+2];
  FreeMem(Bitmap,X*Y+4);
End;

Procedure MakeFontBitmap(Tx:String;var Bufor:Pointer);
Var Size:Longint;
    _Seg,_Ofs,
    _SegDest,_OfsDest:Word;
    X,Y:Byte;
    Ch:Byte;
    Wi,He,Wi2,Temp,T2:Word;
    Col:Byte;
Begin
  Wi:=GetTextWidth(Tx);
  He:=FontInfo.Height;
  If TX='' then Begin Wi:=0;He:=0;end;
  Size:=Wi*He+4;
  If Size>65535 then Exit;
  If FontInfo.ID[1]=#0 then Exit;
  GetMem(Bufor,Size);
  _SegDest:=Seg(Bufor^);
  _OfsDest:=Ofs(Bufor^);
  MemW[_SegDest:_OfsDest]:=Wi;
  MemW[_SegDest:_OfsDest+2]:=He;
  If TX='' then exit;
  _OfsDest:=_OfsDest+4;
  With FontInfo Do
    If FontType=MonoFont Then
      Begin
        If Width>8 Then Wi2:=2 else Wi2:=1;
        For Y:=0 to Height-1 Do
          For Ch:=1 To Ord(Tx[0]) Do
            Begin
              _Seg:=Seg(FontData[Ord(Tx[Ch])]^);
              _Ofs:=Ofs(FontData[Ord(Tx[Ch])]^)+Y*Wi2;
              Temp:=MemW[_Seg:_Ofs];
              For X:=0 To Width-1 Do
                begin
                  T2:=Temp and FontMask[X+(2-Wi2)*8];
                  Col:=0;
                  If T2=FontMask[X+(2-Wi2)*8] Then Col:=FontCol;
                  If (Not TransposeFont) and (T2=0) Then Col:=FontBack;
                  Mem[_SegDest:_OfsDest]:=Col;
                  Inc(_OfsDest);
                end;
            End;
      End
        else
      Begin
        { 256col font type }
        For Y:=0 to Height-1 Do
          For Ch:=1 To Ord(Tx[0]) Do
            For X:=0 to Width-1 Do
              Begin
                _Seg:=Seg(FontData[Ord(Tx[Ch])]^);
                _Ofs:=Ofs(FontData[Ord(Tx[Ch])]^)+X+Width*Y;
                Col:=Mem[_Seg:_Ofs];
                If (not TransposeFont) and (Col=0) then Col:=FontBack;
                Mem[_SegDest:_OfsDest]:=Col;
                Inc(_OfsDest);
              End;
      End;
End;

Procedure OutTextXY(X,Y:Integer;Tx:String);
Var Temp:Pointer;
    Draw:Byte;
Begin
   If TX='' then exit;
   MakeFontBitmap(Tx,Temp);
   If FontInfo.TransposeFont=TRUE then Draw:=NormalDraw else Draw:=FastDraw;
   PutImage(X,Y,Temp^,Draw);
   DisposeBitmap(Temp);
End;

Procedure MakeButton(Txt:Pointer;var Result:Pointer;C1,C2,C3:Byte);
Var _Seg,_Ofs:Word;
    _ResSeg,_ResOfs:Word;
    NewWidth,NewHeight,Width,Height,X,Y:Word;
Begin
 _Seg:=Seg(Txt^);
 _Ofs:=Ofs(Txt^);
 Width:=MemW[_Seg:_Ofs];
 Height:=MemW[_Seg:_Ofs+2];
 _Ofs:=_Ofs+4;
 NewWidth:=Width+2;
 NewHeight:=Height+2;
 GetMem(Result,NewWidth*NewHeight+4);
 _ResSeg:=Seg(Result^);
 _ResOfs:=Ofs(Result^);
 MemW[_ResSeg:_ResOfs]:=NewWidth;
 MemW[_ResSeg:_ResOfs+2]:=NewHeight;
 _ResOfs:=_ResOfs+4;
 For X:=0 to Width Do
   Begin
     Mem[_ResSeg:_ResOfs]:=C1;
     Inc(_ResOfs);
   End;
 Mem[_ResSeg:_ResOfs]:=C2;
 Inc(_ResOfs);
 For Y:=0 To Height-1 Do
   Begin
     Mem[_ResSeg:_ResOfs]:=C1;
     Inc(_ResOfs);
     For X:=0 to Width-1 Do
       Begin
         Mem[_ResSeg:_ResOfs]:=Mem[_Seg:_Ofs];
         Inc(_ResOfs);Inc(_Ofs);
       End;
     Mem[_ResSeg:_ResOfs]:=C3;
     Inc(_ResOfs);
   End;
 Mem[_ResSeg:_ResOfs]:=C2;
 Inc(_ResOfs);
 For X:=0 To Width Do
   Begin
     Mem[_ResSeg:_ResOfs]:=C3;
     Inc(_ResOfs);
   End;
End;

Procedure CreateButton(Tx:String;var Normal,Pressed:Pointer);
Var Temp:Pointer;
    F:TFontHeader;
Begin
  If Tx='' then Begin Normal:=nil;Pressed:=nil;Exit;End;
  F:=FontInfo;
  With FontInfo Do
    Begin
      TransposeFont:=FALSE;
      FontBack:=7;
      FontCol:=0;
    End;
  MakeFontBitmap(Tx,Temp);
  MakeButton(Temp,Normal,15,7,8);
  DisposeBitmap(Temp);
  FontInfo.FontCol:=4;
  MakeFontBitmap(Tx,Temp);
  MakeButton(Temp,Pressed,8,7,15);
  DisposeBitmap(Temp);
  FontInfo:=F;
End;

procedure line(x1,y1,x2,y2,color:integer);

    {Freeware: my bugs - your problem , 29 dec 1993 J.Betts,
     PASCAL echo Fidonet.     please keep this notice intact}

  function sign(x:integer):integer; {like sgn(x) in basic}
  begin if x<0 then sign:=-1 else if x>0 then sign:=1 else sign:=0 end;
  var
    x,y,count,xs,ys,xm,ym:integer;
  begin
    x:=x1;y:=y1;

    xs:=x2-x1;    ys:=y2-y1;

    xm:=sign(xs); ym:=sign(ys);
    xs:=abs(xs);  ys:=abs(ys);

    putpixel(x,y,color);

  if xs > ys
    then begin {flat line <45 deg}
      count:=-(xs div 2);
      while (x <> x2 ) do begin
        count:=count+ys;
        x:=x+xm;
        if count>0 then begin
          y:=y+ym;
          count:=count-xs;
          end;
        putpixel(x,y,color);
        end;
      end
    else begin {steep line >=45 deg}
      count:=-(ys div 2);
      while (y <> y2 ) do begin
        count:=count+xs;
        y:=y+ym;
        if count>0 then begin
          x:=x+xm;
          count:=count-ys;
          end;
        putpixel(x,y,color);
        end;
      end;
  end;

Procedure Rec(X1,Y1,X2,Y2:Word;Color:Byte);
Begin
  Line(X1,Y1,X2,Y1,Color);
  Line(X2,Y1,X2,Y2,Color);
  Line(X1,Y2,X2,Y2,Color);
  Line(X1,Y1,X1,Y2,Color);
End;

Procedure SwitchFont(var HD:TFontHeader;var FD:TFontData);
var
   TempHD:TFontHeader;
   TempPtr:Pointer;
   X:Byte;
Begin
  TempHD:=FontInfo;
  FontInfo:=HD;
  HD:=TempHD;
  For X:=0 to MaxChar do
    Begin
      TempPtr:=FontData[X];
      FontData[X]:=FD[X];
      FD[X]:=TempPtr;
    End;
End;

Begin
  V256Inited:=FALSE;
  StartVirtualX:=0;
  StartVirtualY:=0;
  ScrollMode:=FALSE;
  TransposeScroll:=FALSE;
  v256ErrorCode:=erNoError;
  CustomLoader:=Glupol;
End.
