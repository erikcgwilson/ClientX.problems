unit F2Unit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,

  F1Unit, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TF2 = class(TForm)
    Memo1: TMemo;
    ButtonClose: TButton;
    procedure FormResize(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F2: TF2;
  ImageStatus, ImageNavigation : tImage;

implementation

{$R *.fmx}

procedure TF2.ButtonCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TF2.FormResize(Sender: TObject);
var
   CH, CW : single;  // Adjusted ClientHeight and ClientWidth

   w : single;
   h, xh : single;

   LeftOffset : single; // For when the left has to be shifted due to the buttons
   TopOffset : single;
   Orientation : string;
   rectStatus, rectNavigation : tRectF;
begin
   Memo1.Lines.Add('Resize: ' + inttostr(ClientHeight) + ', ' + inttostr(ClientWidth));

   if ClientWidth = 0 then exit;

   F1.SetBarDetails(F2, ImageStatus, ImageNavigation, ClientHeight, CLientWidth, CH, CW, LeftOffset, TopOffset, rectStatus, rectNavigation, Orientation);

   ImageStatus.Bitmap.SetSize(round(rectStatus.Right), round(rectStatus.Bottom));
   ImageNavigation.Bitmap.SetSize(round(rectNavigation.Right), round(rectNavigation.Bottom));

   F1.WriteBars(ImageStatus, ImageNavigation, rectStatus, rectNavigation, Orientation);

   //Adjust some of the stuff on the screen.

   ButtonClose.Position.X := LeftOffset;
   ButtonClose.Position.Y := TopOffset;

   Memo1.Position.Y := TopOffset + ButtonClose.Height + 10;
   Memo1.Position.X := LeftOffset + 5;
   Memo1.Height := CH - Memo1.Position.Y - 20;
   Memo1.Width := CW - 20;

end;

procedure TF2.Memo1DblClick(Sender: TObject);
begin
   Memo1.Lines.Clear;
end;

end.
