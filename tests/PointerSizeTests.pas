
{$i deltics.inc}

  unit PointerSizeTests;


interface

  uses
    Deltics.Smoketest;


  type
    TPointerSizeTests = class(TTest)
      procedure NativeUIntIsTheExpectedSizeForPlatform;
      procedure IntPointerIsTheExpectedSizeForPlatform;
    end;


implementation

  uses
    Deltics.Pointers,
    Deltics.Smoketest.Test;


  const
    POINTER_SIZE = {$ifdef 64BIT} 8
                   {$else}
                     {$ifdef 32BIT} 4
                     {$else}
                       NEITHER_64BIT_NOR_32BIT_DEFINED
                     {$endif}
                   {$endif};


{ TPointerSizeTests }

  procedure TPointerSizeTests.IntPointerIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(IntPointer)').Assert(sizeof(IntPointer)).Equals(POINTER_SIZE);
  end;


  procedure TPointerSizeTests.NativeUIntIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(NativeUInt)').Assert(sizeof(NativeUInt)).Equals(POINTER_SIZE);
  end;



end.
