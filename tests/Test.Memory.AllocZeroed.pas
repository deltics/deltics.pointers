
{$i deltics.inc}

  unit Test.Memory.AllocZeroed;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryAllocZeroed = class(TTest)
      procedure AllocatesNewMemoryWithBytesZeroed;
    end;


implementation

  uses
    Deltics.Pointers;



{ CopyBytes }

  procedure MemoryAllocZeroed.AllocatesNewMemoryWithBytesZeroed;
  const
    ZEROES: array[1..100] of Byte = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var
    dest: Pointer;
  begin
    Memory.AllocZeroed(dest, Length(ZEROES));
    try
      Test('dest').Assert(dest).IsNotNIL;
      Test('dest').Assert(dest).EqualsBytes(@ZEROES, Length(ZEROES));

    finally
      FreeMem(dest);
    end;
  end;




end.
