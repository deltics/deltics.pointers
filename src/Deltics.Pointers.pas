{
  * MIT LICENSE *

  Copyright © 2020 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Direnko-Smith
  e-mail          : jsmith@deltics.co.nz
  github          : deltics/deltics.rtl
}

{$i deltics.pointers.inc}

  unit Deltics.Pointers;


interface

  uses
    Deltics.Pointers.Memory,
    Deltics.Pointers.Types;


  type
    NativeUInt    = Deltics.Pointers.Types.NativeUInt;
    NativeInt     = Deltics.Pointers.Types.NativeInt;

    IntPointer    = Deltics.Pointers.Types.IntPointer;
    PObject       = Deltics.Pointers.Types.PObject;
    PUnknown      = Deltics.Pointers.Types.PUnknown;

    TPointerArray = Deltics.Pointers.Types.TPointerArray;
    PPointer      = Deltics.Pointers.Types.PPointer;
    PPointerArray = Deltics.Pointers.Types.PPointerArray;


    Memory  = Deltics.Pointers.Memory.Memory;



  function BinToHex(const aBuf: Pointer; const aSize: Integer): String;
  function HexToBin(const aString: String; var aSize: Integer): Pointer; overload;
  procedure HexToBin(const aString: String; var aBuf; const aSize: Integer); overload;

  procedure FillZero(var aDest; const aSize: Integer); overload; deprecated;

  function ByteOffset(const aPointer: Pointer; const aOffset: Integer): PByte; deprecated;

  procedure CopyBytes(const aSource; var aDest; aCount: Integer); overload; deprecated;
  procedure CopyBytes(const aSource; var aDest; aDestOffset: Integer; aCount: Integer); overload; deprecated;
  procedure CopyBytes(const aSource: Pointer; const aDest: Pointer; aCount: Integer); overload; deprecated;



implementation

  uses
    Classes;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function ByteOffset(const aPointer: Pointer; const aOffset: Integer): PByte;
  begin
    result := PByte(NativeInt(aPointer) + aOffset);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function BinToHex(const aBuf: Pointer;
                    const aSize: Integer): String;
  const
    DIGITS = '0123456789abcdef';
  var
    i: Integer;
    c: PByte;
  begin
    result  := '';
    c       := aBuf;

    for i := 1 to aSize do
    begin
      result := result + DIGITS[(c^ and $F0) shr 4 + 1];
      result := result + DIGITS[(c^ and $0F) + 1];
      Inc(c);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function HexToBin(const aString: String;
                    var   aSize: Integer): Pointer;
  begin
    result  := NIL;
    aSize   := Length(aString) div 2;

    if aSize = 0 then
      EXIT;

    GetMem(result, aSize);

    HexToBin(aString, result^, aSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure HexToBin(const aString: String;
                     var   aBuf;
                     const aSize: Integer);
  begin
    if aSize = 0 then
      EXIT;

    Classes.HexToBin(PChar(aString), PANSIChar(@aBuf), aSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure FillZero(var aDest; const aSize: Integer);
  begin
    FillChar(aDest, aSize, 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure CopyBytes(const aSource; var aDest; aCount: Integer);
{$ifdef WIN64}
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
  procedure CopyBytes(const aSource; var aDest; aDestOffset: Integer; aCount: Integer);
  var
    destBytes: PByte;
  begin
    destBytes := PByte(Int64(@aDest) + aDestOffset);
    CopyBytes(aSource, destBytes^, aCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure CopyBytes(const aSource: Pointer; const aDest: Pointer; aCount: Integer);
  begin
    CopyBytes(aSource^, aDest^, aCount);
  end;






end.

