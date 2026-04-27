program F1Prog;

uses
  System.StartUpCopy,
  FMX.Forms,
  F1Unit in 'F1Unit.pas' {F1},
  F2Unit in 'F2Unit.pas' {F2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TF1, F1);
  Application.CreateForm(TF2, F2);
  Application.Run;
end.
