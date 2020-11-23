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

  type
  {$ifdef __DELPHIXE}
    {$ifdef WIN32}
      NativeUInt  = Cardinal;
      NativeInt   = Integer;
    {$else}
      NativeUInt  = UInt64;
      NativeInt   = Int64;
    {$endif}
  {$endif}

    IntPointer  = NativeUInt;
    PObject     = ^TObject;
    PUnknown    = ^IUnknown;


  function BinToHex(const aBuf: Pointer; const aSize: Integer): String;
  function HexToBin(const aString: String; var aSize: Integer): Pointer; overload;
  procedure HexToBin(const aString: String; var aBuf; const aSize: Integer); overload;
  procedure FillZero(var aDest; const aSize: Integer); overload;

  function ByteOffset(const aPointer: Pointer; const aOffset: Integer): PByte;


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
                    var aSize: Integer): Pointer;
  begin
    result  := NIL;
    aSize   := Length(aString) div 2;

    if aSize = 0 then
      EXIT;

    result := AllocMem(aSize);
    HexToBin(aString, result^, aSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure HexToBin(const aString: String;
                     var aBuf;
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



end.
