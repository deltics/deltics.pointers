
{$i deltics.pointers.inc}

  unit Deltics.Pointers.Types;


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
  {$else}
    NativeUInt  = System.NativeUInt;
    NativeInt   = System.NativeInt;
  {$endif}

    IntPointer  = NativeUInt;
    PObject     = ^TObject;
    PUnknown    = ^IUnknown;

    TPointerArray = array of Pointer;
    PPointer      = ^Pointer;
    PPointerArray = array of PPointer;


implementation

end.
