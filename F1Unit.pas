unit F1Unit;

//This programme is written to get around a couple of android problems.
// Android 15 brought the status bar and the navigation bar into the area
// provided for the user to write on.  Sort of neat, and uses some of the
// space which is otherwise not available, but the side effects are
// 1. The lettering in the space bar may be difficult to read due to
// the colour of the user's images and things, and
// 2. If you put your buttons at the bottom of the screen, they are no
// longer useful, as they are now behind the navigation bar.

// There is another problem which rather baffles me.
// If in Form.Create you access the CLientHeight and ClientWidth, you will
// find that the value for the vertical one (depending on orientation) is
// short by the height iof the status bar.  On top of this, screen rotation
// can lead to the CLientHeight and ClientWidths values being crossed, with
// odd results!

// Chester Wilson,
// Wombat Systems,
// Australia.

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Objects, FMX.Platform, Math, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.DialogService, Androidapi.Helpers, Androidapi.JNI,
  Androidapi.JNI.App, Androidapi.JNI.Net, Androidapi.JNI.Support,
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Provider,
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge, Androidapi.JNI.Os,
  FMX.Media, Androidapi.JNI.Util, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls;


type
  TF1 = class(TForm)
    Memo1: TMemo;
    ButtonShowF2: TButton;

   procedure GetStatusBarHeights;

   procedure SetBarDetails (Form : tForm; var xImageStatus : tImage; var xImageNavigation : tImage;
      FormClientHeight, FormClientWidth : integer; var CH : single; var CW : single;
      var LeftOffset : single; var TopOffset : single; var RectStatus : tRectF; var RectNavigation : tRectf;
      var Orientation : string);

   procedure WriteBars (var ImageStatus : tImage; var ImageNavigation : tImage;
      var RectStatus : tRectF; var RectNavigation : tRectf; var Orientation : string);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonShowF2Click(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F1: TF1;

  tempint1, tempint2, tempint3, tempint4 : integer;   //Debugging stuff


  ImageStatus, ImageNavigation : tImage;           //Images for the status and navigation bars
  StatusBarHeight, NavigationBarHeight : integer;  //Heights of these bars
  OriginalClientHeight, OriginalClientWidth : integer;  //Original client height and width - almost!

implementation

{$R *.fmx}

uses F2Unit;


procedure TF1.ButtonShowF2Click(Sender: TObject);
begin
   F2.Show;
end;

procedure TF1.FormCreate(Sender: TObject);
begin
   GetStatusBarHeights;   // Get the heights of the status and the navigation bars.

   // The Client height and Client Width available here are short by th4 status bar height,
   // depending on the orientation of the device.

   if ClientHeight > ClientWidth then
   begin
      OriginalClientHeight := max(ClientHeight, ClientWidth) + StatusBarHeight;
      OriginalClientWidth := min(ClientHeight, ClientWidth);
   end
   else
   begin
      OriginalClientHeight := max(ClientHeight, ClientWidth);
      OriginalClientWidth := min(ClientHeight, ClientWidth) + StatusBarHeight;
   end;
end;



procedure TF1.FormResize(Sender: TObject);
var
   CH, CW : single;  // Adjusted ClientHeight and ClientWidth
   LeftOffset : single; // For when the left has to be shifted due to the buttons
   TopOffset : single;
   Orientation : string;
   rectStatus, rectNavigation : tRectF;
   s : string;
begin
   Memo1.Lines.Add('Resize: ' + inttostr(ClientHeight) + ', ' + inttostr(ClientWidth));

   if ClientWidth = 0 then exit;    // Get zero in the first call, I think from the FormCreate calling.

   // Set up the parameters for the usable screen area - ie without the status and navigation bars, and
   // the top and left margins for different orientations..
   // The ClientHeight and ClientWidth arguments are no longer required (but left in so I can use this
   // routine in other programmes without having to change them all!).

   // The usable rectangle is CH x CW, with left and top margins of LeftOffset and TopOffset.
   // The rectangles are for the images used to cover the status and navigation bar areas,
   // though the navigation bar one is a bit limited as it just sits under the opacity of
   // the navigation bar rather than taking over its colour.

   SetBarDetails(F1, ImageStatus, ImageNavigation, ClientHeight, ClientWidth, CH, CW, LeftOffset, TopOffset, rectStatus, rectNavigation, Orientation);

   // The SetSizes cause the images to be written on the form on which they are called,
   // hence they have to be done here, not in SetBarDetails.  I think this is because
   // SetSize is responsible for the construction of the canvas for the image.

   ImageStatus.Bitmap.SetSize(round(rectStatus.Right), round(rectStatus.Bottom));
   ImageNavigation.Bitmap.SetSize(round(rectNavigation.Right), round(rectNavigation.Bottom));

   // Actually write the status and navigation images (only necessary in androids
   // from 15 on).

   WriteBars(ImageStatus, ImageNavigation, rectStatus, rectNavigation, Orientation);

   //Adjust some of the stuff on the screen.

   ButtonShowF2.Position.X := LeftOffset;
   ButtonShowF2.Position.Y := TopOffset;

   Memo1.Position.Y := TopOffset + ButtonShowF2.Height + 10;
   Memo1.Position.X := LeftOffset + 5;
   Memo1.Height := CH - Memo1.Position.Y - 20;
   Memo1.Width := CW - 20;
end;





procedure tF1.GetStatusBarHeights;
var
  LID: Integer;
  LResources: JResources;
begin
  StatusBarHeight := 0;
  LResources := TAndroidHelper.Context.getResources;
  LID := LResources.getIdentifier(StringToJString('status_bar_height'), StringToJString('dimen'), StringToJString('android'));

  if LID > 0 then
    StatusBarHeight := round(LResources.getDimensionPixelSize(LID) / TAndroidHelper.DisplayMetrics.density);


  NavigationBarHeight := 0;
  LResources := TAndroidHelper.Context.getResources;
  LID := LResources.getIdentifier(StringToJString('navigation_bar_height'), StringToJString('dimen'), StringToJString('android'));

  if LID > 0 then
    NavigationBarHeight := round(LResources.getDimensionPixelSize(LID) / TAndroidHelper.DisplayMetrics.density);

   //Minimise if earlier android.

   if TJBuild_VERSION.JavaClass.SDK_INT < 36 then     //Android 16 produces 36 here !
   begin
      StatusBarHeight := 0;
      NavigationBarHeight := 0;
   end;
end;


procedure TF1.Memo1DblClick(Sender: TObject);
begin
   Memo1.Lines.Clear;
end;



procedure tF1.SetBarDetails (Form : tForm; var xImageStatus : tImage; var xImageNavigation : tImage;
   FormClientHeight, FormClientWidth : integer; var CH : single; var CW : single;
   var LeftOffset : single; var TopOffset : single; var RectStatus : tRectF; var RectNavigation : tRectf;
   var Orientation : string);
// FormClient Height, FormClientWidth used to be provided by the calling form using the ClientHeight and ClientWidth parameters
// Note that they are zero on the first call, so if they are zero, do nothing.
// They are no longer used (see note above).
// CH and CW are the returned clientheight and clientwidth for where we will put our components
// LeftOffset and TopOffset are the offsets from the top and the side for where the status and navigation bars go
// RectStatus, RectNavigation contain the positions and sizes for the status bar rectangles
// - left, top for the positions, width and height for the sizes.
var
   LService: IFMXScreenService;
   tso : tScreenOrientation;
   s : string;
begin
   OriginalCLientHeight := max(ClientHeight, OriginalClientHeight);
   FormClientHeight := OriginalClientHeight;
   FormClientWidth := OriginalCLientWidth;

   CH := FormClientHeight;
   CW := FormClientWidth;
   LeftOffset := 0;
   TopOffset := StatusBarHeight;

   if StatusBarHeight <= 0 then GetStatusBarHeights;

   if xImageStatus = nil then xImageStatus := tImage.Create(Form);
   if xImageStatus.Bitmap = nil then xImageStatus.Bitmap := tBitmap.Create;
   xImageStatus.Parent := Form;

   if xImageNavigation = nil then xImageNavigation := tImage.Create(Form);
   if xImageNavigation.Bitmap = nil then xImageNavigation.Bitmap := tBitmap.Create;
   xImageNavigation.Parent := Form;

   if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, LService) then
   begin
      tso := LService.GetScreenOrientation; //This is more accurate than using ClientHeight and CLientWidth

      if tso = tScreenOrientation.Portrait then
      begin
         Orientation := 'Portrait';

         Memo1.Lines.Add('Portrait');
         Memo1.Lines.Add(inttostr(FormClientHeight) + ', ' + inttostr(FormClientWidth));

         CW := FormClientWidth;
         CH := FormClientHeight - StatusBarHeight - NavigationBarHeight;
         LeftOffset := 0;

         RectStatus.Left := 0;
         RectStatus.Top := 0;
         RectStatus.Right := FormClientWidth;
         RectStatus.Bottom := StatusBarHeight;

         RectNavigation.Left := 0;
         RectNavigation.Top := FormClientHeight - NavigationBarHeight;
         RectNavigation.Right := FormClientWidth;
         RectNavigation.Bottom := NavigationBarHeight;
      end;

      if tso = tScreenOrientation.Landscape then  //Landscape - rotated to the left
      begin
         Orientation := 'Landscape';

         Memo1.Lines.Add('Landscape');
         Memo1.Lines.Add(inttostr(ClientHeight) + ', ' + inttostr(ClientWidth));

         FormClientHeight := OriginalClientWidth;
         FormClientWidth := OriginalCLientHeight;

         // Status bar at the top; navigation bar on the right.

         CH := FormClientHeight - StatusBarHeight;
         CW := FormClientWidth - NavigationBarHeight;

         //Status bar image position X, Y:  0,0
         //Status bar image size  StatusBarHeight, ClientHeight

         RectStatus.Left := 0;
         RectStatus.Top := 0;
         RectStatus.Right := FormClientWidth;
         RectStatus.Bottom := StatusBarHeight;;

         //Navigation bar image position X, Y: 0, ClientHeight - NavigationBarHeight
         //Navigation bar image size ClientWidth NavigationBarHeight

         RectNavigation.Left := FormClientWidth - NavigationBarHeight;
         RectNavigation.Top := 0;
         RectNavigation.Right := NavigationBarHeight;
         RectNavigation.Bottom := FormClientWidth;
      end;

      if tso = tScreenOrientation.InvertedLandscape then //Landscape - rotated to the right
      begin
         Orientation := 'InvertedLandscape';

         Memo1.Lines.Add('Inverted Landscape');
         Memo1.Lines.Add(inttostr(ClientHeight) + ', ' + inttostr(ClientWidth));

         //Status bar at the top; Navigation bar on the left.

         FormClientHeight := OriginalClientWidth;
         FormClientWidth := OriginalCLientHeight;

         CW := FormClientWidth - NavigationBarHeight;
         CH := FormClientHeight - StatusBarHeight;
         LeftOffset := NavigationBarHeight;

         RectStatus.Left := 0;
         RectStatus.Top := 0;
         RectStatus.Right := FormClientWidth;
         RectStatus.Bottom := StatusBarHeight;

         RectNavigation.Left := 0;
         RectNavigation.Top := 0;
         RectNavigation.Right := NavigationBarHeight;
         RectNavigation.Bottom := FormClientWidth;
      end;

      if tso = tScreenOrientation.InvertedPortrait then
      begin
         //Don't think I can get this one.
         Orientation := 'InvertedPortrait';

         Memo1.Lines.Add('Inverted Portrait');
         Memo1.Lines.Add(inttostr(ClientHeight) + ', ' + inttostr(ClientWidth));

         //Treat as portrait.

         CH := FormClientHeight - StatusBarHeight - NavigationBarHeight;
         TopOffset := StatusBarHeight;

         RectStatus.Left := 0;
         RectStatus.Top := 0;
         RectStatus.Right := FormClientWidth;
         RectStatus.Bottom := StatusBarHeight;

         RectNavigation.Left := 0;
         RectNavigation.Top := FormClientHeight - NavigationBarHeight;
         RectNavigation.Right := FormClientWidth;
         RectNavigation.Bottom := NavigationBarHeight;
       end;
   end
   else
   begin
      //Now we're fucked!  Let's hope it never happens!
      //Just leave things untouched and put up with it.

      //Use "if orientation <> ''" to test for this.
   end;


   //Set the positions and the sizes of the images.

   xImageStatus.Position.X := RectStatus.Left;
   xImageStatus.Position.Y := RectStatus.Top;
   xImageStatus.Width := RectStatus.Right;
   xImageStatus.Height := RectStatus.Bottom;

   xImageNavigation.Position.X := RectNavigation.Left;
   xImageNavigation.Position.Y := RectNavigation.Top;
   xImageNavigation.Width := RectNavigation.Right;
   xImageNavigation.Height := RectNavigation.Bottom;

  if TJBuild_VERSION.JavaClass.SDK_INT < 36 then
   begin
      CH := FormClientHeight;
      CW := FormClientWidth;
      LeftOffset := 0;
      TopOffset := 0;
   end;

   Memo1.GoToTextEnd;
end;



procedure tF1.WriteBars (var ImageStatus : tImage; var ImageNavigation : tImage;
   var RectStatus : tRectF; var RectNavigation : tRectf; var Orientation : string);

//I don't know if this idea is valid, but it comes from an earlier version using CLientHeight and ClientWidth:
// The ClientHeight and ClientWidth appear to be defined for each form - hence they have to be passed as
// arguments to this routine or otherwise you get the values for this form, which are just held over from when
// this form was last active - and may have nothing to do with the values for the current form!

var
   rect : tRectF;
   brush : tBrush;
   s : string;
begin
   if TJBuild_VERSION.JavaClass.SDK_INT < 36 then exit;  //All of this is unnecessary until version 15.

   brush := tBrush.Create(tBrushKind.solid, tAlphaColorRec.Red);///.Black);

   // Draw the status bar

   rect := tRectF.Create(0, 0, RectStatus.Right, RectStatus.Bottom);
   ImageStatus.Bitmap.Canvas.BeginScene;
   ImageStatus.Bitmap.Canvas.FillRect(rect, 1, brush);
   ImageStatus.Bitmap.Canvas.EndScene;

   //Now for the navigation bar

   brush.Color := tAlphaColorRec.Springgreen;

///   rect := tRectF.Create(0, 0, 100, 100);
   rect := tRectF.Create(0, 0, RectNavigation.Right, RectNavigation.Bottom);
   ImageNavigation.Bitmap.Canvas.BeginScene;
   ImageNavigation.Bitmap.Canvas.FillRect(rect, 1, brush);
   ImageNavigation.Bitmap.Canvas.EndScene;

   brush.Destroy;
end;


end.

