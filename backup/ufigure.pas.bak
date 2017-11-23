unit uFigure;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, Types, uLog, math;

type
TFigure = class
  PColor: TColor;
  BColor: TColor;
  BStyle: TBrushStyle;
  PStyle: TPenStyle;
  RounX: integer;
  RounY: integer;
  PWhidth: integer;
  MaxPoint: DoublePoint;
  MinPoint: DoublePoint;
  x0, y0, x1, y1: double;
  procedure Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint); virtual;
  procedure DrawSelect(ACanvas: TCanvas);
  constructor Create(LastPoint, NowPoint: DoublePoint); virtual;
  function Insides(Now: TPoint): boolean; virtual; abstract;
end;

TLine = class(TFigure)
  procedure Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint); override;
  function Insides(Now: TPoint): boolean; override;
end;

TRectangle = class(TFigure)
  procedure Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint); override;
  function Insides(Now: TPoint): boolean; override;
end;

TPencil = class(TFigure)
  pic: array of DoublePoint;
  constructor Create(LastPoint, NowPoint: DoublePoint); override;
  procedure Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint); override;
  function Insides(Now: TPoint): boolean; override;
end;

TEllipse = class(TFigure)
  procedure Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint); override;
  function Insides(Now: TPoint): boolean; override;
  end;
  RFigures = record
  Figures: TFigure;
  Select: boolean;
end;

var
  Figures: array of TFigure;
  GScale: double;
  GOffset: DoublePoint;
  NowFigure: TFigure;
  PaintBoxWidth: integer;
  PaintBoxHeight: integer;

  procedure SelectingFalse();


implementation

  procedure SelectingFalse();
  var
  i: integer;
    begin
    for i:=0 to High(Figures) do Figures[i].Select:=false;
    end;
  function BelongsRectangle(x0, y0, x1, y1: integer; Now: TPoint): boolean;
   begin
if (x0 <= Now.x) and (Now.x <= x1) and (Now.y <= y1) and (y0 <= Now.y) then
BelongsRectangle:=true
else
 BelongsRectangle:=false;
end;
     function BelongsEllipse(x0, y0, x1, y1: integer; Now: TPoint): boolean;
     var
      a, b: double;
        begin
        a:=(x1-x0)/2;
        b:=(y1-y0)/2;
        if (a <> 0) and (b <>0) then begin
        if ((((sqr(Now.x-x0-a)/(a*a))+(sqr(Now.y-y0-b)/(b*b))))<=1) then
        BelongsEllipse:=true
        else
        BelongsEllipse:=false;
        end else
        BelongsEllipse:=false;
        end;
function BelongsLine(x0, y0, x1, y1: integer; Now: TPoint; whidth: integer): boolean;
  var
  kx, ky: double;
    begin
    BelongsLine:=false;
    if ((sqr(x1-x0)+sqr(y1-y0)) <> 0) then begin
    kx:=((y1-y0)*(SelectingLineIndent+(whidth div 2)))/sqrt(sqr(x1-x0)+sqr(y1-y0));
    ky:=((x1-x0)*(SelectingLineIndent+(whidth div 2)))/sqrt(sqr(x1-x0)+sqr(y1-y0));
    if ((((((((Now.y-(y0-ky))*((x1+kx)-(x0+kx)))-((Now.x-(x0+kx))*((y1-ky)-(y0-ky))))<=0) and ((((Now.y-(y0+ky))*((x1-kx)-(x0-kx)))-((Now.x-(x0-kx))*((y1+ky)-(y0+ky))))>=0)) or
    (((((Now.y-(y0-ky))*((x1+kx)-(x0+kx)))-((Now.x-(x0+kx))*((y1-ky)-(y0-ky))))>=0) and ((((Now.y-(y0+ky))*((x1-kx)-(x0-kx)))-((Now.x-(x0-kx))*((y1+ky)-(y0+ky))))<=0))) and //формула о нахождении между двумя параллельными прямыми
    ((((x0-abs(kx) <= Now.x) and (Now.x <= x1+abs(kx))) or ((x1-abs(kx) <= Now.x) and (Now.x <= x0+abs(kx)))) and
    (((y0-abs(ky) <= Now.y) and (Now.y <= y1+abs(ky))) or ((y1-abs(ky) <= Now.y) and (Now.y <= y0+abs(ky)))))) or //превращение прямой в отрезок
    BelongsEllipse(x0-(SelectingLineIndent+(whidth div 2)), y0-(SelectingLineIndent+(whidth div 2)), x0+(SelectingLineIndent+(whidth div 2)), y0+(SelectingLineIndent+(whidth div 2)), Now) or
    BelongsEllipse(x1-(SelectingLineIndent+(whidth div 2)), y1-(SelectingLineIndent+(whidth div 2)), x1+(SelectingLineIndent+(whidth div 2)), y1+(SelectingLineIndent+(whidth div 2)), Now)) then begin
    BelongsLine:=true;
end;
end;
    end;
procedure TFigure.Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint);
begin
  ACanvas.Pen.Color:=PColor;
  ACanvas.Brush.Color:=BColor;
  ACanvas.Pen.Width:=PWhidth;
  ACanvas.Brush.Style:=BStyle;
  ACanvas.Pen.Style:=PStyle;
  GScale:=Scale;
  GOffset:=Offset;
end;

constructor TFigure.Create(LastPoint, NowPoint: DoublePoint);
begin
  x0:=LastPoint.x;
  y0:=LastPoint.y;
  x1:=NowPoint.x;
  y1:=NowPoint.y;
  RounX:=RoundX;
  RounY:=RoundY;
  PColor:=PenColor;
  BColor:=BrushColor;
  BStyle:=BrushStyle.Style;
  PStyle:=PenStyle.Style;
  if PenStyle.Style = psClear then
  PWhidth:=0
  else
  PWhidth:=PenWidthInt;
  MaxPoint.x:=max(x0, x1);
  MaxPoint.y:=max(y0, y1);
  MinPoint.x:=min(x0, x1);
  MinPoint.Y:=min(y0, y1);
end;

procedure TFigure.DrawSelect(ACanvas: TCanvas);

  begin
   ACanvas.Pen.Color:=clGreen;
   ACanvas.Pen.Style:=psSolid;
   ACanvas.Brush.Style:=bsClear;
   ACanvas.Pen.Width:=SelectingPenWidth;
   ACanvas.Rectangle(W2S(MinPoint.x, MinPoint.Y).x-SelectingMargin-(PWhidth div 2), W2S(MinPoint.x, MinPoint.Y).y-SelectingMargin-(PWhidth div 2),
   W2S(MaxPoint.x, MaxPoint.y).x+SelectingMargin+(PWhidth div 2), W2S(MaxPoint.x, MaxPoint.y).y+SelectingMargin+(PWhidth div 2));
   ACanvas.Pen.Color:=clPurple;
   ACanvas.Pen.Style:=psDash;
   ACanvas.Rectangle(W2S(MinPoint.x, MinPoint.y).x-SelectingMargin+2+SelectingPenWidth-(PWhidth div 2), W2S(MinPoint.x, MinPoint.y).y-SelectingMargin+2+SelectingPenWidth-(PWhidth div 2),
   W2S(MaxPoint.x, MaxPoint.y).x+SelectingMargin-2-SelectingPenWidth+(PWhidth div 2), W2S(MaxPoint.x, MaxPoint.y).y+SelectingMargin-2-SelectingPenWidth
end;

constructor TPencil.Create(LastPoint, NowPoint: DoublePoint);
begin
  SetLength(pic, 1);
  PColor:=PenColor;
  PWhidth:=PenWidthInt;
  pic[high(pic)].x:=NowPoint.x;
  pic[high(pic)].y:=NowPoint.y;
  MaxPoint.x:=NowPoint.x;
  MaxPoint.y:=NowPoint.y;
  MinPoint.x:=NowPoint.x;
  MinPoint.Y:=NowPoint.y;
end;

procedure TLine.Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint);
begin
  Inherited Draw(ACanvas, Scale, Offset);
  ACanvas.Line(W2S(x0, y0), W2S(x1, y1));
end;

function TLine.Insides(Now: TPoint): boolean;
var
  a, b: TPoint;
begin
  a:=W2S(x0, y0);
  b:=W2S(x1, y1);
  if BelongsLine(a.x, a.y, b.x, b.y, Now, PWhidth) then begin
    Insides:=true;
  end else
    Insides:=false;
end;

procedure TRectangle.Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint);
var
  LastPoint: TPoint;
  NowPoint: TPoint;
begin
  Inherited Draw(ACanvas, Scale, Offset);
  LastPoint:=W2S(x0, y0);
  NowPoint:=W2S(x1, y1);
  ACanvas.RoundRect(LastPoint.x, LastPoint.y, NowPoint.x, NowPoint.y, RounX, RounY);
end;

function TRectangle.Insides(Now: TPoint): boolean;
var
  a, b: TPoint;
begin
  a:=W2S(x0, y0);
  b:=W2S(x1, y1);
  if (BelongsRectangle(a.x-(PWhidth div 2), a.y+(RounY div 2), (b.x+(PWhidth div 2)), b.y-(RounY div 2), Now)) or
    (BelongsRectangle(a.x+(RounX div 2), (a.y-(PWhidth div 2)), b.x-(RounX div 2), (b.y+(PWhidth div 2)), Now)) or
    (BelongsEllipse(a.x-(PWhidth div 2), a.y-(PWhidth div 2), a.x+2*(RounX div 2)+(PWhidth div 2), a.y+2*(RounY div 2)+(PWhidth div 2), Now)) or
    (BelongsEllipse(b.x-2*(RounX div 2)-(PWhidth div 2), b.y-2*(RounY div 2)-(PWhidth div 2), b.x+(PWhidth div 2), b.y+(PWhidth div 2), Now)) or
    (BelongsEllipse(b.x-2*(RounX div 2)-(PWhidth div 2), a.y-(PWhidth div 2), b.x+(PWhidth div 2), a.y+(PWhidth div 2)+2*(RounY div 2), Now)) or
    (BelongsEllipse(a.x-(PWhidth div 2), b.y-(PWhidth div 2)-2*(RounY div 2), a.x+(PWhidth div 2)+2*(RounX div 2), b.y+(PWhidth div 2), Now)) then begin
    Insides:=true;
  end else
    Insides:=false;
end;

procedure TPencil.Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint);
var
  i: uint64;
begin
  Inherited Draw(ACanvas, Scale, Offset);
  SetLength(pic, length(pic)+1);
  pic[high(pic)].x:=x1;
  pic[high(pic)].y:=y1;
  for i:=1 to high(pic) do
    ACanvas.Line(W2S(pic[i-1].x, pic[i-1].y), W2S(pic[i].x, pic[i].y));
end;

function TPencil.Insides(Now: TPoint): boolean;
var
  a, b: TPoint;
  i: integer;
begin
  Insides:=false;
  a:=W2S(pic[0].x, pic[0].y);
  b:=W2S(pic[0].x, pic[0].y);
  for i:=1 to high(pic) do begin
    a:=W2S(pic[i-1].x, pic[i-1].y);
    b:=W2S(pic[i].x, pic[i].y);
    if BelongsLine(a.x, a.y, b.x, b.y, Now, PWhidth) then begin
      Insides:=true;
    end;
  end;
end;

procedure TEllipse.Draw(ACanvas: TCanvas; Scale: double; Offset: DoublePoint);
var
  LastPoint: TPoint;
  NowPoint: TPoint;
begin
  Inherited Draw(ACanvas, Scale, Offset);
  LastPoint:=W2S(x0, y0);
  NowPoint:=W2S(x1, y1);
  ACanvas.Ellipse(LastPoint.x, LastPoint.y, NowPoint.x, NowPoint.y);
end;

function TEllipse.Insides(Now: TPoint): boolean;
var
  a, b: TPoint;
begin
  a:=W2S(x0, y0);
  b:=W2S(x1, y1);
  if BelongsEllipse(a.x-(PWhidth div 2), a.y-(PWhidth div 2), b.x+(PWhidth div 2), b.y+(PWhidth div 2), Now) then begin
    Insides:=true;
  end else
  Insides:=false;
end;

end.

