
{$i deltics.inc}

  unit Test.Memory.Copy;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryCopy = class(TTest)
      procedure CopiesSpecifiedNumberOfBytesUsingPointers;
      procedure CopiesSpecifiedNumberOfBytesUsingUntypedArgs;
    end;


implementation

  uses
    Deltics.Pointers;



{ CopyBytes }

  procedure MemoryCopy.CopiesSpecifiedNumberOfBytesUsingPointers;
  const
    BUFSIZE   = 1024;
    BYTECOUNT = 512;
  var
    src: Pointer;
    dest: Pointer;
  begin
    GetMem(src,   BUFSIZE);
    GetMem(dest,  BUFSIZE);
    try
      Memory.Randomize(src,   BUFSIZE);
      Memory.Randomize(dest,  BUFSIZE);

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest are different to src', [BYTECOUNT]).Assert(dest).HasUnequalBytes(src, BYTECOUNT);

      Memory.Copy(src, dest, BYTECOUNT);

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest == src', [BYTECOUNT]).Assert(dest).EqualsBytes(src, BYTECOUNT);

    finally
      FreeMem(dest);
      FreeMem(src);
    end;
  end;




  procedure MemoryCopy.CopiesSpecifiedNumberOfBytesUsingUntypedArgs;
  const
    BUFSIZE   = 1024;
    BYTECOUNT = 512;
  var
    src: Pointer;
    dest: Pointer;
  begin
    GetMem(src,   BUFSIZE);
    GetMem(dest,  BUFSIZE);
    try
      Memory.Randomize(src,   BUFSIZE);
      Memory.Randomize(dest,  BUFSIZE);

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest are different to src', [BYTECOUNT]).Assert(dest).HasUnequalBytes(src, BYTECOUNT);

      Memory.Copy(src^, dest^, BYTECOUNT);

      Test('Bytes of dest are different to src').Assert(dest).HasUnequalBytes(src, BUFSIZE);
      Test('First {bytes:%d} of dest == src', [BYTECOUNT]).Assert(dest).EqualsBytes(src, BYTECOUNT);

    finally
      FreeMem(dest);
      FreeMem(src);
    end;
  end;



end.
