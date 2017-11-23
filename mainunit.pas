unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, Spin, StdCtrls, Types, uFigure,
  uLog, uTool, math;

const
  KeyZ = 90;
  KeyCtrl = 17;
  { TGraphicsEditor }

 type
  TGraphicsEditor = class(TForm)
    New1: TMenuItem;
    ParameterTool: TPanel;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Help: TMenuItem;
    Exit1: TMenuItem;
    About: TMenuItem;
    PaintBox: TPaintBox;
    ScrollX: TScrollBar;
    ScrollY: TScrollBar;
    Toolbar: TPanel;
    Zoom: TFloatSpinEdit;
    procedure AboutClick(Sender: TObject);
    procedure ArmClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MagnifierClick(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure PenColorColorChanged(Sender: TObject);
    procedure ScrollXChange(Sender: TObject);
    procedure ScrollYChange(Sender: TObject);
    procedure ToolBitBtnClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  GraphicsEditor: TGraphicsEditor;
  NowTool: TTool;

implementation

{$R *.lfm}

{ TGraphicsEditor }

procedure Scroll();
var
  a: TPoint;
begin
  a.x:=round(MinPoint.x*Scale);
  a.y:=round(MinPoint.y*Scale);
  if 0 > a.x then GraphicsEditor.ScrollX.Min:=a.x
  else GraphicsEditor.ScrollX.Min:=0;
  if 0 > a.y then GraphicsEditor.ScrollY.Min:=a.y
  else GraphicsEditor.ScrollY.Min:=0;
  a.x:=round(MaxPoint.x*Scale);
  a.y:=round(MaxPoint.y*Scale);
  if GraphicsEditor.PaintBox.Width < a.x then GraphicsEditor.ScrollX.Max:=a.x-GraphicsEditor.PaintBox.Width
  else GraphicsEditor.ScrollX.Max:=0;
  if GraphicsEditor.PaintBox.Height < a.y then GraphicsEditor.ScrollY.Max:=a.y-GraphicsEditor.PaintBox.Height
  else GraphicsEditor.ScrollY.Max:=0;

  GraphicsEditor.ScrollX.Position:=ScrollXPosition;
  GraphicsEditor.ScrollY.Position:=ScrollYPosition;
end;

procedure ResetParameterTool();
begin
  GraphicsEditor.ParameterTool.Free;
  GraphicsEditor.ParameterTool:=TPanel.Create(GraphicsEditor.ToolBar);
  GraphicsEditor.ParameterTool.Parent:=GraphicsEditor.ToolBar;
  GraphicsEditor.ParameterTool.Top:=((high(Tools) div 2)+2)*50+10;
  GraphicsEditor.ParameterTool.Height:=300;
  GraphicsEditor.ParameterTool.Width:=110;
end;

procedure TGraphicsEditor.FormCreate(Sender: TObject);
var
  ABitBtn: TBitBtn;
  i: integer;
begin
  for i:=0 to high(Tools) do begin
    ABitBtn:=TBitBtn.Create(ToolBar);
    ABitBtn.Top:=(i div 2)*50+10;
    if (i mod 2) = 0 then
      ABitBtn.Left:=10
    else
      ABitBtn.Left:=60;
    ABitBtn.Height:=40;
    ABitBtn.Width:=40;
    ABitBtn.Glyph.LoadFromFile('BMP\'+Tools[i].Name+'.bmp');
    ABitBtn.Tag:=i;
    ABitBtn.Parent:=ToolBar;
    ABitBtn.onClick:=@ToolBitBtnClick;
  end;
  Zoom.Top:=((high(Tools) div 2)+1)*50+10;
  Zoom.Left:=10;
  GraphicsEditor.Constraints.Minheight:=((high(Tools) div 2)+9)*50+10;
  SetLength(Figures, 0);
  isDrowing:= false;
  MaxPoint.x:=0;
  MaxPoint.y:=0;
  MinPoint.x:=2000000;
  MinPoint.y:=2000000;
  ScrollXPosition:= 0;
  ScrollYPosition:= 0;
  Scale:=100;
  LastScale:=Scale;
  PaintBoxWidth:=PaintBox.Width;
  PaintBoxHeight:=PaintBox.Height;
  Offset.x:=0;
  Offset.y:=0;
  StandardTool:= stNo;
  isEmpty:=true;
  PenColor:=clBlack;
  BrushColor:=clWhite;
  PenWidthInt:=1;
  Tool:= Tools[0].FClass;
  BrushStyle.Index:=1;
  BrushStyle.Style:=TypeBrushStyle.Style[BrushStyle.Index];
  RoundY:=20;
  RoundX:=20;
  MainZoom:=Zoom;
  ResetParameterTool();
  Tool.Param(ParameterTool);
  PaintB:=PaintBox;
  NowFigure:=Nil;
  SelectingFalse();
  Scroll();
end;

procedure TGraphicsEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if ((Key = KeyZ) and (ssCtrl in Shift) and (isDrowing = false)) then begin
    if (Length(Figures)>0) then begin
      SetLength(Figures, Length(Figures)-1);
      if(Length(Figures)=0) then isEmpty:=true;
      PaintBox.Refresh;
    end;
  end
end;

procedure TGraphicsEditor.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift)then begin
    isDrowing:=true;
    Tool.MouseDown(Button, Shift, X, Y);
  end;
end;

procedure TGraphicsEditor.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if isDrowing then begin
    Tool.MouseMove(Shift, X, Y);
    PaintBox.Refresh;
  end;
end;

procedure TGraphicsEditor.PaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  Tool.MouseUp(PaintBox, Button, Shift, X, Y);
  ScrollXPosition:=-round(Offset.x);
  ScrollYPosition:=-round(Offset.y);
  isDrowing:=false;
  PaintBox.Refresh;
end;

procedure TGraphicsEditor.PaintBoxPaint(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to high(Figures) do Figures[i].Figures.Draw(PaintBox.Canvas, Scale, Offset);
  if (isDrowing) and (NowFigure <> Nil) then begin
    NowFigure.Draw(PaintBox.Canvas, Scale, Offset);
  end;
  if (Tool = TSelectingTool) then begin
  for i:=0 to high(Figures) do begin
  if Figures[i].Select then Figures[i].Figures.DrawSelect(PaintBox.Canvas);
  end;
end;
end;

procedure TGraphicsEditor.MagnifierClick(Sender: TObject);
begin
  StandardTool:=stZoom;
end;

procedure TGraphicsEditor.ArmClick(Sender: TObject);
begin
  StandardTool:=stArm;
end;

procedure TGraphicsEditor.FormResize(Sender: TObject);
begin
  PaintBoxHeight:=PaintBox.Height;
  PaintBoxWidth:=PaintBox.Width;
  Scroll();
end;

procedure TGraphicsEditor.ScrollXChange(Sender: TObject);
begin
  Offset.x:=-ScrollX.Position;
  PaintBox.Invalidate;
end;

procedure TGraphicsEditor.ScrollYChange(Sender: TObject);
begin
  Offset.y:=-ScrollY.Position;
  PaintBox.Invalidate;
end;


procedure TGraphicsEditor.Exit1Click(Sender: TObject);
begin
  Close();
end;


procedure TGraphicsEditor.AboutClick(Sender: TObject);
begin
  ShowMessage('монетчиков дмитрий, Б8103б');
end;

procedure TGraphicsEditor.New1Click(Sender: TObject);
begin
  SetLength(Figures, 0);
  isDrowing:= false;
  Tool:= Tools[0].FClass;
  PaintBox.Invalidate;
end;

procedure TGraphicsEditor.PenColorColorChanged(Sender: TObject);
begin

end;

procedure TGraphicsEditor.ToolBitBtnClick(Sender: TObject);
begin
  Tool:=Tools[(Sender as TBitBtn).Tag].FClass;
  (Sender as TBitBtn).SetFocus;
  ResetParameterTool();
  Tool.Param(ParameterTool);
  StandardTool:=stNo;
end;

end.
