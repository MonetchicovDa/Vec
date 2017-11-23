unit uLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, Spin, StdCtrls, Types, math;

const
    ZoomStep = 100;
    SelectingMargin = 10;
    SelectingPenWidth = 3;
    SelectingLineIndent = 3;
type

DoublePoint = record
  x: double;
  y: double;
end;

RNowBrushStyle = record
   Style: TBrushStyle;
   Index: integer;
end;

RNowPenStyle = record
   Style: TPenStyle;
   Index: integer;
end;

OffsetPoint = record
  x: double;
  y: double;
end;

var
  isDrowing: boolean;
  MaxPoint: DoublePoint;
  MinPoint: DoublePoint;
  PaintB: TPaintBox;
  Offset: DoublePoint;
  Scale: double;
  LastScale: double;
  LastPoint: TPoint;
  StandardTool: (stNo, stZoom, stArm);
  isEmpty: boolean;
  PenWidthInt: integer;
  ScrollXPosition: longint;
  ScrollYPosition: longint;
  PenColor: TColor;
  BrushColor: Tcolor;
  BrushStyle: RNowBrushStyle;
  PenStyle: RNowPenStyle;
  MainZoom: TFloatSpinEdit;
  RoundX: integer;
  RoundY: integer;

function W2S(x, y: double): TPoint;
function S2W(x, y: integer): DoublePoint;
procedure ExtCoordinates(a: DoublePoint);

implementation

function W2S(x, y: double): TPoint;
begin
  W2S.x:=round((x*Scale)+Offset.x);
  W2S.y:=round((y*Scale)+Offset.y);
end;

function S2W(x, y: integer): DoublePoint;
begin
  S2W.x:=(x-Offset.x)/Scale;
  S2W.y:=(y-Offset.y)/Scale;
end;

procedure ExtCoordinates(a: DoublePoint);
begin
  if MaxPoint.x < a.x then
    MaxPoint.x:=a.x;
  if MinPoint.x > a.x then
    MinPoint.x:=a.x;
  if MaxPoint.y < a.y then
    MaxPoint.y:=a.y;
  if MinPoint.y > a.y then
    MinPoint.y:=a.y;
end;

end.

