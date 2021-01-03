
{$i deltics.pointers.inc}

  unit Deltics.Pointers.Memory;


interface

  uses
    Deltics.Pointers.Types;


  type
    Memory = class
    public
      class procedure Alloc(var aPointer: Pointer; const aNumBytes: Integer); {$ifdef InlineMethods} inline; {$endif}
      class procedure AllocCopy(var aPointer: Pointer; const aNumBytes: Integer; const aSource: Pointer); //{$ifdef InlineMethods} inline; {$endif}
      class procedure AllocZeroed(var aPointer: Pointer; const aNumBytes: Integer); {$ifdef InlineMethods} inline; {$endif}
      class function ByteOffset(const aPointer: Pointer; const aOffset: Integer): Pointer;
      class procedure Copy(const aSource: Pointer; const aDest: Pointer; aNumBytes: Integer);
      class procedure Free(var aPointer: Pointer); overload; {$ifdef InlineMethods} inline; {$endif}
      class procedure Free(aPointers: PPointerArray); overload;
      class procedure Randomize(const aDest: Pointer; const aNumBytes: Integer); overload;
      class procedure Randomize(const aDest: Pointer; const aNumBytes: Integer; const aMin: Byte); overload;
      class procedure Randomize(const aDest: Pointer; const aNumBytes: Integer; const aMin, aMax: Byte); overload;
      class procedure Zeroize(const aDest: Pointer; const aNumBytes: Integer); overload; {$ifdef InlineMethods} inline; {$endif}
    end;



implementation

  uses
    Classes,
    {$ifdef 64BIT}
      {$ifdef MSWINDOWS}
        Windows,
      {$else}
        {$message fatal '64-bit platform not supported'}
      {$endif}
    {$endif}
    Deltics.Pointers;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure CopyBytes(const aSource; var aDest; aCount: Integer);
{$ifdef 64BIT}
  begin
    CopyMemory(@aDest, @aSource, aCount);
  end;
{$else}
  asm
                      // ECX = Count
                      // EAX = Const Source
                      // EDX = Var Dest
                      // If there are no bytes to copy, just quit
                      // altogether; there's no point pushing registers.
    Cmp   ECX,0
    Je    @JustQuit
                      // Preserve the critical Delphi registers.
    push  ESI
    push  EDI
                      // Move Source into ESI (SOURCE register).
                      // Move Dest into EDI (DEST register).
                      // This might not actually be necessary, as I'm not using MOVsb etc.
                      // I might be able to just use EAX and EDX;
                      // there could be a penalty for not using ESI, EDI, but I doubt it.
                      // This is another thing worth trying!
    Mov   ESI, EAX
    Mov   EDI, EDX
                      // The following loop is the same as repNZ MovSB, but oddly quicker!
  @Loop:
    Mov   AL, [ESI]   // get a source byte
    Inc   ESI         // bump source address
    Mov   [EDI], AL   // Put it into the destination
    Inc   EDI         // bump destination address
    Dec   ECX         // Dec ECX to note how many we have left to copy
    Jnz   @Loop       // If ECX <> 0, then loop.
                      // Pop the critical Delphi registers that we've altered.
    pop   EDI
    pop   ESI
  @JustQuit:
  end;
{$endif}



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Alloc(var   aPointer: Pointer;
                               const aNumBytes: Integer);
  begin
    GetMem(aPointer, aNumBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.AllocCopy(var   aPointer: Pointer;
                                   const aNumBytes: Integer;
                                   const aSource: Pointer);
  begin
    GetMem(aPointer, aNumBytes);
    CopyBytes(aSource^, aPointer^, aNumBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.AllocZeroed(var   aPointer: Pointer;
                                     const aNumBytes: Integer);
  begin
    GetMem(aPointer, aNumBytes);
    FillChar(aPointer^, aNumBytes, 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Memory.ByteOffset(const aPointer: Pointer;
                                   const aOffset: Integer): Pointer;
  begin
    result := Pointer(IntPointer(aPointer) + Cardinal(aOffset));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Copy(const aSource: Pointer;
                              const aDest: Pointer;
                                    aNumBytes: Integer);
  begin
    CopyBytes(aSource^, aDest^, aNumBytes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Free(var aPointer: Pointer);
  begin
    FreeMem(aPointer);
    aPointer := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Free(aPointers: PPointerArray);
  var
    i: Integer;
  begin
    for i := Low(aPointers) to High(aPointers) do
    begin
      FreeMem(aPointers[i]^);
      aPointers[i]^ := NIL;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Randomize(const aDest: Pointer;
                                   const aNumBytes: Integer);
  var
    i: Integer;
    intPtr: PInteger;
    bytePtr: PByte absolute intPtr;
    bytesLeft: Integer;
  begin
    intPtr := PInteger(aDest);
    for i := 1 to (aNumBytes div 4) do
    begin
      intPtr^ := Random(MaxInt);
      Inc(intPtr);
    end;

    bytesLeft := aNumBytes mod 4;
    for i := 1 to bytesLeft do
    begin
      bytePtr^ := Byte(Random(255));
      Inc(bytePtr);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Randomize(const aDest: Pointer;
                                   const aNumBytes: Integer;
                                   const aMin: Byte);
  begin
    Randomize(aDest, aNumBytes, aMin, 255);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Randomize(const aDest: Pointer;
                                   const aNumBytes: Integer;
                                   const aMin, aMax: Byte);
  var
    i: Integer;
    range: Integer;
    bytePtr: PByte;
  begin
    bytePtr := aDest;
    range   := aMax - aMin + 1;

    for i := 1 to aNumBytes do
    begin
      bytePtr^ := Byte(Random(range)) + aMin;
      Inc(bytePtr);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Memory.Zeroize(const aDest: Pointer;
                                 const aNumBytes: Integer);
  begin
    FillChar(aDest^, aNumBytes, 0);
  end;




end.
