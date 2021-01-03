
{$i deltics.inc}

  unit Test.Memory.AllocCopy;


interface

  uses
    Deltics.Smoketest;


  type
    MemoryAllocCopy = class(TTest)
      procedure AllocatesNewMemoryWithBytesCopiedFromSource;
    end;


implementation

  uses
    Deltics.Pointers;



{ CopyBytes }

  procedure MemoryAllocCopy.AllocatesNewMemoryWithBytesCopiedFromSource;
  const
    BUFSIZE = 1024;
  var
    src: Pointer;
    dest: Pointer;
  begin
    GetMem(src, BUFSIZE);
    try
      Memory.Randomize(src, BUFSIZE);

      Memory.AllocCopy(dest, BUFSIZE, src);
      try
        Test('dest').Assert(dest).DoesNotEqual(src);
        Test('dest').Assert(dest).EqualsBytes(src, BUFSIZE);

      finally
        FreeMem(dest);
      end;

    finally
      FreeMem(src);
    end;
  end;




end.
