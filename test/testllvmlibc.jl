## --- Malloc and free!

    p = malloc(100)
    @test isa(p, Ptr)
    @test free(p) == 0

    p = malloc(0x10)
    @test isa(p, Ptr)
    @test free(p) == 0

    p = malloc(Int16(100))
    @test isa(p, Ptr)
    @test free(p) == 0

## ---- Memcpy, memcmp, etc.

    a = MallocArray{Float64}(undef, 100)
    @test memcpy!(a, ones(100)) == 0
    @test a == ones(100)

    @test memcmp(a, a, 100) === Int32(0)
    @test memcmp(c"foo", c"foo", 3) === Int32(0)
    @test memcmp(c"foo", "foo", 3) === Int32(0)
    @test memcmp(c"foo", c"bar", 3) != 0
    free(a)


    @test isa(StaticTools.time(), Int64)
    @test StaticTools.time() > 10^9
