unit uTool;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, Spin, StdCtrls, Types, uFigure,
  uLog, math;

type
  TComboBoxName = array of string;

  TStyleBrushArray = array of TBrushStyle;
  RBrushStyle = record
    Name: TComboBoxName;
    Style: TStyleBrushArray;
  end;

    TStylePenArray = array of TPenStyle;
  RPenStyle = record
    Name: TComboBoxName;
    Style: TStylePenArray;
  end;

  TTool = class
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual; abstract;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual; abstract;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual; abstract;
    class procedure DeleteFigures(Sender: TObject);
    class procedure OnUpFigures(Sender: TObject);
    class procedure OnDown(Sender: TObject);
    class procedure CreateButton(ToolBar: TPanel; Name: string; Proced: TNotifyEvent);
    class procedure Param(ToolBar: TPanel); virtual; abstract;
    class procedure PenColorButtonChanged(Sender: TObject);
    class procedure PenWhidthChange(Sender: TObject);
    class procedure BrushColorButtonChanged(Sender: TObject);
    class procedure BrushStyleChange(Sender: TObject);
    class procedure RoundXChange(Sender: TObject);
    class procedure RoundYChange(Sender: TObject);
    class procedure CreateColorButton(ToolBar: TPanel; Name: string; LastColor: TColor; Proced: TNotifyEvent);
    class procedure CreateSpinEdit(ToolBar: TPanel; Name: string; LastWidth: integer; Proced: TNotifyEvent);
    class procedure CreateComboBox(ToolBar: TPanel; Name: string; NameBrushStyle: TComboBoxName; Index: integer; Proced: TNotifyEvent);
  end;

  TMagnifierTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TArmTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;


  TSelectingTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
end;


  TPencilTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TLineTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TRectangleTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TRoundRecTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TEllipseTool = class(TTool)
    class procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class procedure Param(ToolBar: TPanel); override;
  end;

  TToolClass = class of TTool;

  RTools = record
    FClass: TToolClass;
    Name: string;
  end;

var
  Tool: TToolClass;
  Tools: array of RTools;
  TypeBrushStyle: RBrushStyle;

implementation

class procedure TTool.PenColorButtonChanged(Sender: TObject);
begin
  PenColor:=(Sender as TColorButton).ButtonColor;
end;

class procedure TTool.BrushColorButtonChanged(Sender: TObject);
begin
  BrushColor:=(Sender as TColorButton).ButtonColor;
end;

class procedure TTool.PenWhidthChange(Sender: TObject);
begin
  PenWidthInt:=(Sender as TSpinEdit).Value;
end;

class procedure TTool.BrushStyleChange(Sender: TObject);
begin
  BrushStyle.Index:=(Sender as TComboBox).ItemIndex;
  BrushStyle.Style:=TypeBrushStyle.Style[BrushStyle.Index];
end;

class procedure TTool.RoundXChange(Sender: TObject);
begin
  RoundX:=(Sender as TSpinEdit).Value;
end;

class procedure TTool.RoundYChange(Sender: TObject);
begin
  RoundY:=(Sender as TSpinEdit).Value;
end;

class procedure TTool.DeleteFigures(Sender: TObject);
var
  i, j: integer;
begin
  j:=0;
  for i:=0 to High(Figures) do begin
    if Figures[i].Select then
      FreeAndNil(Figures[i])
    else begin
      Figures[j]:=Figures[i];
      j:=j+1;
    end;
  end;
  SetLength(Figures, j);
  PaintB.Invalidate;
end;

class procedure TTool.OnUpFigures(Sender: TObject);
var
  i, j: integer;
  a: array of RFigures;
begin
  j:=0;
  SetLength(a, 0);
  for i:=0 to High(Figures) do begin
    if Figures[i].Select then begin
      SetLength(a, Length(a)+1);
      a[High(a)]:=Figures[i];
    end else begin
      Figures[j]:=Figures[i];
      j:=j+1;
    end;
  end;
  for i:=j to High(Figures) do begin
    Figures[i]:=a[i-j];
  end;
PaintB.Invalidate;
end;

class procedure TTool.OnDown(Sender: TObject);
var
  i, j: integer;
  a: array of RFigures;
begin
  j:=High(Figures);
  SetLength(a, 0);
  for i:=High(Figures) downto 0 do begin
      if Figures[i].Select then begin
      SetLength(a, Length(a)+1);
      a[High(a)]:=Figures[i];
    end else begin
      Figures[j]:=Figures[i];
      j:=j-1;
    end;
  end;
  for i:=0 to j do begin
    Figures[i]:=a[i];
  end;
  PaintB.Invalidate;
end;


class procedure TTool.CreateColorButton(ToolBar: TPanel; Name: string; LastColor: TColor; Proced: TNotifyEvent);
var
  PenColorButton: TColorButton;
begin
  PenColorButton:=TColorButton.Create(ToolBar);
  PenColorButton.Align:=alTop;
  PenColorButton.Layout:=blGlyphBottom;
  PenColorButton.Caption:=Name;
  PenColorButton.Height:=40;
  PenColorButton.Parent:=ToolBar;
  PenColorButton.ButtonColor:=LastColor;
  PenColorButton.OnColorChanged:=Proced;
end;

  class procedure TTool.CreateButton(ToolBar: TPanel; Name: string; Proced: TNotifyEvent);
var
  AButton: TBitBtn;
begin
  AButton:=TBitBtn.Create(ToolBar);
  AButton.Align:=alTop;
  AButton.Layout:=blGlyphBottom;
  AButton.Caption:=Name;
  AButton.Height:=40;
  AButton.Parent:=ToolBar;
  AButton.OnClick:=Proced;
end;


class procedure TTool.CreateSpinEdit(ToolBar: TPanel; Name: string; LastWidth: integer; Proced: TNotifyEvent);
var
  Panel: TPanel;
  Lab: TLabel;
  SpinEdit: TSpinEdit;
begin
  Panel:=TPanel.Create(ToolBar);
  Panel.Parent:=ToolBar;
  Panel.Align:=alTop;
  Panel.Height:=40;
  Lab:=TLabel.Create(Panel);
  Lab.Parent:=Panel;
  Lab.Align:=alTop;
  Lab.Caption:=Name;
  SpinEdit:=TSpinEdit.Create(Panel);
  SpinEdit.Align:=alBottom;
  SpinEdit.Parent:=Panel;
  SpinEdit.Value:=LastWidth;
  SpinEdit.OnChange:=Proced;
end;

class procedure TTool.CreateComboBox(ToolBar: TPanel; Name: string; NameBrushStyle: TComboBoxName; Index: integer; Proced: TNotifyEvent);
var
  Panel: TPanel;
  Lab: TLabel;
  ComboBox: TComboBox;
  i: Integer;
begin
  Panel:=TPanel.Create(ToolBar);
  Panel.Parent:=ToolBar;
  Panel.Align:=alTop;
  Panel.Height:=40;
  Lab:=TLabel.Create(Panel);
  Lab.Parent:=Panel;
  Lab.Align:=alTop;
  Lab.Caption:=Name;
  ComboBox:=TComboBox.Create(Panel);
  ComboBox.Align:=alBottom;
  ComboBox.Parent:=Panel;
  for i:=0 to High(NameBrushStyle) do
    ComboBox.Items[i]:=NameBrushStyle[i];
  ComboBox.ItemIndex:=Index;
  ComboBox.OnChange:=Proced;
end;

{TMagnifierTool}
class procedure TMagnifierTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  LastPoint:=Point(x, y);
end;

class procedure TMagnifierTool.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

class procedure TMagnifierTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then begin
    if Scale=MainZoom.Value then
      if MainZoom.Value < ZoomStep then
        MainZoom.Value:=MainZoom.Value+(ZoomStep div 10)
      else
        MainZoom.Value:=MainZoom.Value+(ZoomStep);
    Scale:=MainZoom.Value;
    Offset.x:=round(((Offset.x-x)*Scale/LastScale)+x);
    Offset.y:=round(((Offset.y-y)*Scale/LastScale)+y);
    LastScale:=Scale;
  end else if (Button = mbRight)then begin
    if Scale=MainZoom.Value then
      if MainZoom.Value <= ZoomStep then
        MainZoom.Value:=MainZoom.Value-(ZoomStep div 10)
      else
        MainZoom.Value:=MainZoom.Value-(ZoomStep);
    Scale:=MainZoom.Value;
    Offset.x:=round(((Offset.x-x)*Scale/LastScale)+x);
    Offset.y:=round(((Offset.y-y)*Scale/LastScale)+y);
    LastScale:=Scale;
  end;
end;

class procedure TMagnifierTool.Param(ToolBar: TPanel);
begin
end;

{TArmTool}
class procedure TArmTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  LastPoint:=Point(x, y);
end;

class procedure TArmTool.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Offset.x:=round(((Offset.x+x-LastPoint.x)));
  ScrollXPosition:=-round(Offset.x);
  Offset.y:=round(((Offset.y+y-LastPoint.y)));
  ScrollYPosition:=-round(Offset.y);
  LastPoint:=Point(x, y);
end;

class procedure TArmTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

class procedure TArmTool.Param(ToolBar: TPanel);
begin
end;

class procedure TSelectingTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RX: integer;
  RY: integer;
  PC: TColor;
  BC: TColor;
  BS: TBrushStyle;
  PS: TPenStyle;
  PW: integer;
begin
  SelectingFalse();
  RX:=RoundX;
  RY:=RoundY;
  PC:=PenColor;
  BC:=BrushColor;
  BS:=BrushStyle.Style;
  PS:=PenStyle.Style;
  PW:=PenWidthInt;
  RoundX:=0;
  RoundY:=0;
  PenColor:=clBlack;
  BrushColor:=clRed;
  BrushStyle.Style:=bsDiagCross;
  PenStyle.Style:=psSolid;
  PenWidthInt:=1;
  NowFigure:=TRectangle.Create(S2W(x, y), S2W(x, y));
  RoundX:=RX;
  RoundY:=RY;
  PenColor:=PC;
  BrushColor:=BC;
  BrushStyle.Style:=BS;
  PenStyle.Style:=PS;
  PenWidthInt:=PW;
end;

class procedure TSelectingTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
end;
class procedure TSelectingTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  DPoint: DoublePoint;
  APoint: TPoint;
  BPoint: TPoint;
  Delta: TPoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=Max(NowFigure.x0, DPoint.x);
  NowFigure.x0:=Min(NowFigure.x0, DPoint.x);
  NowFigure.y1:=Max(NowFigure.y0, DPoint.y);
  NowFigure.y0:=Min(NowFigure.y0, DPoint.y);
  APoint:=W2S(NowFigure.x0, NowFigure.y0);
  BPoint:=W2S(NowFigure.x1, NowFigure.y1);
  Delta.x:=BPoint.x-APoint.x;
  Delta.y:=BPoint.y-APoint.y;
  if (Delta.x <= 2) and (Delta.y <= 2) then begin
    for i:=high(Figures) downto 0 do begin
      if Figures[i].Figures.Insides(Point(x, y)) then begin
          Figures[i].Select:=true;
          break;
      end
    end;
  end else begin
    for i:=0 to high(Figures) do begin
    if (((W2S(Figures[i].Figures.MinPoint.x, Figures[i].Figures.MinPoint.y).x-(Figures[i].Figures.PWhidth div 2) >=APoint.x) and ((W2S(Figures[i].Figures.MinPoint.x, Figures[i].Figures.MinPoint.y).y-(Figures[i].Figures.PWhidth div 2))>=APoint.y)) and
        (((W2S(Figures[i].Figures.MaxPoint.x, Figures[i].Figures.MaxPoint.y).x+(Figures[i].Figures.PWhidth div 2))<=BPoint.x) and ((W2S(Figures[i].Figures.MaxPoint.x, Figures[i].Figures.MaxPoint.y).y+(Figures[i].Figures.PWhidth div 2))<=BPoint.y))) then begin
        Figures[i].Select:=true;
      end;
    end;
  end;
  FreeAndNil(NowFigure);
end;
class procedure TSelectingTool.Param(ToolBar: TPanel);
begin
  CreateButton(ToolBar, 'Delete', @DeleteFigures);
  CreateButton(ToolBar, 'On Down', @OnDown);
  CreateButton(ToolBar, 'On Up', @OnUpFigures);
end;

class procedure TPencilTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  NowFigure:=TPencil.Create(S2W(x, y), S2W(x, y));
  ExtCoordinates(S2W(x, y));
end;

class procedure TPencilTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
  NowFigure.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  NowFigure.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  NowFigure.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  NowFigure.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
  ExtCoordinates(S2W(x, y));
end;

class procedure TPencilTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
  SetLength(Figures, Length(Figures)+1);
  Figures[high(Figures)].Figures:=NowFigure;
  Figures[high(Figures)].Select:=false;
  Figures[high(Figures)].Figures.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  Figures[high(Figures)].Figures.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
  ExtCoordinates(S2W(x, y));
end;

class procedure TPencilTool.Param(ToolBar: TPanel);
begin
    CreateColorButton(ToolBar, 'Pen Color', PenColor,@PenColorButtonChanged);
    CreateSpinEdit(ToolBar, 'Pen Whidth', PenWidthInt, @PenWhidthChange);
end;

{TLineTool}
class procedure TLineTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  NowFigure:=TLine.Create(S2W(x, y), S2W(x, y));
  ExtCoordinates(S2W(x, y));
end;

class procedure TLineTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
end;

class procedure TLineTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
  SetLength(Figures, Length(Figures)+1);
  Figures[high(Figures)].Figures:=NowFigure;
  Figures[high(Figures)].Select:=false;
  ExtCoordinates(S2W(x, y));
  Figures[high(Figures)].Figures.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  Figures[high(Figures)].Figures.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
end;

class procedure TLineTool.Param(ToolBar: TPanel);
begin
  CreateColorButton(ToolBar, 'Pen Color', PenColor,@PenColorButtonChanged);
  CreateSpinEdit(ToolBar, 'Pen Whidth', PenWidthInt, @PenWhidthChange);
end;

{TRectangleTool}
class procedure TRectangleTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RX: integer;
  RY: integer;
begin
  RX:=RoundX;
  RY:=RoundY;
  RoundX:=0;
  RoundY:=0;
  NowFigure:=TRectangle.Create(S2W(x, y), S2W(x, y));
  ExtCoordinates(S2W(x, y));
  RoundX:=RX;
  RoundY:=RY;
end;

class procedure TRectangleTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
end;

class procedure TRectangleTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=Max(NowFigure.x0, DPoint.x);
  NowFigure.x0:=Min(NowFigure.x0, DPoint.x);
  NowFigure.y1:=Max(NowFigure.y0, DPoint.y);
  NowFigure.y0:=Min(NowFigure.y0, DPoint.y);
  SetLength(Figures, Length(Figures)+1);
  Figures[high(Figures)].Figures:=NowFigure;
  Figures[high(Figures)].Select:=false;
  Figures[high(Figures)].Figures.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  Figures[high(Figures)].Figures.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
  ExtCoordinates(S2W(x, y));
end;

class procedure TRectangleTool.Param(ToolBar: TPanel);
begin
  CreateColorButton(ToolBar, 'Brush Color', BrushColor, @BrushColorButtonChanged);
  CreateColorButton(ToolBar, 'Pen Color', PenColor, @PenColorButtonChanged);
  CreateSpinEdit(ToolBar, 'Pen Whidth', PenWidthInt, @PenWhidthChange);
  CreateComboBox(ToolBar, 'Brush Style', TypeBrushStyle.Name, BrushStyle.Index, @BrushStyleChange);
end;

{TRoundRecTool}
class procedure TRoundRecTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  NowFigure:=TRectangle.Create(S2W(x, y), S2W(x, y));
  ExtCoordinates(S2W(x, y));
end;

class procedure TRoundRecTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
end;

class procedure TRoundRecTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=Max(NowFigure.x0, DPoint.x);
  NowFigure.x0:=Min(NowFigure.x0, DPoint.x);
  NowFigure.y1:=Max(NowFigure.y0, DPoint.y);
  NowFigure.y0:=Min(NowFigure.y0, DPoint.y);
  SetLength(Figures, Length(Figures)+1);
  Figures[high(Figures)].Figures:=NowFigure;
  Figures[high(Figures)].Select:=false;
  Figures[high(Figures)].Figures.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  Figures[high(Figures)].Figures.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
  ExtCoordinates(S2W(x, y));
end;

class procedure TRoundRecTool.Param(ToolBar: TPanel);
begin
  CreateSpinEdit(ToolBar, 'Round Y', RoundY, @RoundYChange);
  CreateSpinEdit(ToolBar, 'Round X', RoundX, @RoundXChange);
  CreateColorButton(ToolBar, 'Brush Color', BrushColor, @BrushColorButtonChanged);
  CreateColorButton(ToolBar, 'Pen Color', PenColor, @PenColorButtonChanged);
  CreateSpinEdit(ToolBar, 'Pen Whidth', PenWidthInt, @PenWhidthChange);
  CreateComboBox(ToolBar, 'Brush Style', TypeBrushStyle.Name, BrushStyle.Index, @BrushStyleChange);
end;

{TEllipseTool}
class procedure TEllipseTool.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  NowFigure:=TEllipse.Create(S2W(x, y), S2W(x, y));
  ExtCoordinates(S2W(x, y));
end;

class procedure TEllipseTool.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=DPoint.x;
  NowFigure.y1:=DPoint.y;
end;

class procedure TEllipseTool.Param(ToolBar: TPanel);
begin
  CreateColorButton(ToolBar, 'Brush Color', BrushColor, @BrushColorButtonChanged);
  CreateColorButton(ToolBar, 'Pen Color', PenColor,@PenColorButtonChanged);
  CreateSpinEdit(ToolBar, 'Pen Whidth', PenWidthInt, @PenWhidthChange);
  CreateComboBox(ToolBar, 'Brush Style', TypeBrushStyle.Name, BrushStyle.Index, @BrushStyleChange);
end;

class procedure TEllipseTool.MouseUp(Pb: TPaintBox; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DPoint: DoublePoint;
begin
  DPoint:=S2W(x, y);
  NowFigure.x1:=Max(NowFigure.x0, DPoint.x);
  NowFigure.x0:=Min(NowFigure.x0, DPoint.x);
  NowFigure.y1:=Max(NowFigure.y0, DPoint.y);
  NowFigure.y0:=Min(NowFigure.y0, DPoint.y);
  SetLength(Figures, Length(Figures)+1);
  Figures[high(Figures)].Figures:=NowFigure;
  Figures[high(Figures)].Select:=false;
  Figures[high(Figures)].Figures.MinPoint.x:=Min(NowFigure.MinPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MinPoint.y:=Min(NowFigure.MinPoint.y, S2W(x, y).y);
  Figures[high(Figures)].Figures.MaxPoint.x:=Max(NowFigure.MaxPoint.x, S2W(x, y).x);
  Figures[high(Figures)].Figures.MaxPoint.y:=Max(NowFigure.MaxPoint.y, S2W(x, y).y);
  ExtCoordinates(S2W(x, y));
end;

class procedure RegisterTool(ATool: TToolClass; AName: string);
begin
  SetLength(Tools, Length(Tools) + 1);
  Tools[High(Tools)].FClass:= ATool;
  Tools[High(Tools)].Name:=AName;
end;

class procedure RegisterBrushSt(AStyle: TBrushStyle; AName: string);
begin
  SetLength(TypeBrushStyle.Name, Length(TypeBrushStyle.Name)+1);
  SetLength(TypeBrushStyle.Style, Length(TypeBrushStyle.Style)+1);
  TypeBrushStyle.Name[High(TypeBrushStyle.Name)]:=AName;
  TypeBrushStyle.Style[High(TypeBrushStyle.Style)]:=AStyle;
end;

initialization

RegisterTool(TPencilTool, 'Pencil');
RegisterTool(TLineTool, 'Line');
RegisterTool(TRectangleTool, 'Rectangle');
RegisterTool(TRoundRecTool, 'RoundRec');
RegisterTool(TEllipseTool, 'Ellipse');
RegisterTool(TMagnifierTool, 'Magnifier');
RegisterTool(TArmTool, 'Arm');
RegisterTool(TSelectingTool, 'Selecting');

RegisterBrushSt(bsClear, 'clear');
RegisterBrushSt(bsSolid, 'Solid');

end.

