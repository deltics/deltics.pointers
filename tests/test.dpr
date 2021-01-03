
{$define CONSOLE}

{$i deltics.inc}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Pointers in '..\src\Deltics.Pointers.pas',
  Deltics.Pointers.Memory in '..\src\Deltics.Pointers.Memory.pas',
  Deltics.Pointers.Types in '..\src\Deltics.Pointers.Types.pas',
  Test.PointerSize in 'Test.PointerSize.pas',
  Test.Memory.Copy in 'Test.Memory.Copy.pas',
  Test.Memory.Randomize in 'Test.Memory.Randomize.pas',
  Test.Memory.AllocCopy in 'Test.Memory.AllocCopy.pas',
  Test.Memory.AllocZeroed in 'Test.Memory.AllocZeroed.pas';

begin
  TestRun.Test(PointerSize);
  TestRun.Test(MemoryRandomize);
  TestRun.Test(MemoryCopy);
  TestRun.Test(MemoryAllocCopy);
  TestRun.Test(MemoryAllocZeroed);
end.
