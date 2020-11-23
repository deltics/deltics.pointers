
{$define CONSOLE}

{$i deltics.inc}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Pointers in '..\src\Deltics.Pointers.pas',
  PointerSizeTests in 'PointerSizeTests.pas';

begin
  TestRun.Test(TPointerSizeTests);
end.
