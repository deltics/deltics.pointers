
{$i test.inc}

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
    Deltics.Pointers;


{ TPointerSizeTests }

  procedure TPointerSizeTests.IntPointerIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(IntPointer)').Assert(sizeof(IntPointer)).Equals({$ifdef 64BIT} 8 {$else} 4 {$endif});
  end;


  procedure TPointerSizeTests.NativeUIntIsTheExpectedSizeForPlatform;
  begin
    Test('sizeof(NativeUInt)').Assert(sizeof(NativeUInt)).Equals({$ifdef 64BIT} 8 {$else} 4 {$endif});
  end;



end.
