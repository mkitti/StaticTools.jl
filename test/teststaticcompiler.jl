# Setup
testpath = pwd()
scratch = tempdir()
cd(scratch)

## --- Times table, file IO, mallocarray
let
    # Attempt to compile
    # We have to start a new Julia process to get around the fact that Pkg.test
    # disables `@inbounds`, but ironically we can use `--compile=min` to make that
    # faster.
    status = -1
    try
        isfile("times_table") && rm("times_table")
        status = run(`julia --compile=min $testpath/scripts/times_table.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/times_table.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Attempt to run
    println("5x5 times table:")
    status = -1
    try
        status = run(`./times_table 5 5`)
    catch e
        @warn "Could not run $(scratch)/times_table"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
    # Test ascii output
    @test parsedlm(Int, c"table.tsv", '\t') == (1:5)*(1:5)'
    # Test binary output
    @test fread!(szeros(Int, 5,5), c"table.b") == (1:5)*(1:5)'
end

## --- "withmallocarray"-type do-block pattern
let
    # Compile...
    status = -1
    try
        isfile("withmallocarray") && rm("withmallocarray")
        status = run(`julia --compile=min $testpath/scripts/withmallocarray.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/withmallocarray.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Run...
    println("3x3 malloc arrays via do-block syntax:")
    status = -1
    try
        status = run(`./withmallocarray 3 3`)
    catch e
        @warn "Could not run $(scratch)/withmallocarray"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
end

## --- Random number generation
let
    # Compile...
    status = -1
    try
        isfile("rand_matrix") && rm("rand_matrix")
        status = run(`julia --compile=min $testpath/scripts/rand_matrix.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/rand_matrix.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Run...
    println("5x5 uniform random matrix:")
    status = -1
    try
        status = run(`./rand_matrix 5 5`)
    catch e
        @warn "Could not run $(scratch)/rand_matrix"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
end

let
    # Compile...
    status = -1
    try
        isfile("randn_matrix") && rm("randn_matrix")
        status = run(`julia --compile=min $testpath/scripts/randn_matrix.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/randn_matrix.jl"
        println(e)
    end
    @static if Sys.isapple()
        @test isa(status, Base.Process)
        @test isa(status, Base.Process) && status.exitcode == 0
    end

    # Run...
    println("5x5 Normal random matrix:")
    status = -1
    try
        status = run(`./randn_matrix 5 5`)
    catch e
        @warn "Could not run $(scratch)/randn_matrix"
        println(e)
    end
    @static if Sys.isapple()
        @test isa(status, Base.Process)
        @test isa(status, Base.Process) && status.exitcode == 0
    end
end

## --- Test LoopVectorization integration
@static if LoopVectorization.VectorizationBase.has_feature(Val{:x86_64_avx2})
    let
        # Compile...
        status = -1
        try
            isfile("loopvec_product") && rm("loopvec_product")
            status = run(`julia --compile=min $testpath/scripts/loopvec_product.jl`)
        catch e
            @warn "Could not compile $testpath/scripts/loopvec_product.jl"
            println(e)
        end
        @test isa(status, Base.Process)
        @test isa(status, Base.Process) && status.exitcode == 0

        # Run...
        println("10x10 table sum:")
        status = -1
        try
            status = run(`./loopvec_product 10 10`)
        catch e
            @warn "Could not run $(scratch)/loopvec_product"
            println(e)
        end
        @test isa(status, Base.Process)
        @test isa(status, Base.Process) && status.exitcode == 0
        @test parsedlm(c"product.tsv",'\t')[] == 3025
    end
end

let
    # Compile...
    status = -1
    try
        isfile("loopvec_matrix") && rm("loopvec_matrix")
        status = run(`julia --compile=min $testpath/scripts/loopvec_matrix.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/loopvec_matrix.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Run...
    println("10x5 matrix product:")
    status = -1
    try
        status = run(`./loopvec_matrix 10 5`)
    catch e
        @warn "Could not run $(scratch)/loopvec_matrix"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
    A = (1:10) * (1:5)'
    # Check ascii output
    @test parsedlm(c"table.tsv",'\t') == A' * A
    # Check binary output
    @test fread!(szeros(5,5), c"table.b") == A' * A
end

let
    # Compile...
    status = -1
    try
        isfile("loopvec_matrix_stack") && rm("loopvec_matrix_stack")
        status = run(`julia --compile=min $testpath/scripts/loopvec_matrix_stack.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/loopvec_matrix_stack.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Run...
    println("10x5 matrix product:")
    status = -1
    try
        status = run(`./loopvec_matrix_stack`)
    catch e
        @warn "Could not run $(scratch)/loopvec_matrix_stack"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
    A = (1:10) * (1:5)'
    @test parsedlm(c"table.tsv",'\t') == A' * A
end


## --- Test string handling

let
    # Compile...
    status = -1
    try
        isfile("print_args") && rm("print_args")
        status = run(`julia --compile=min $testpath/scripts/print_args.jl`)
    catch e
        @warn "Could not compile $testpath/scripts/print_args.jl"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0

    # Run...
    println("String indexing and handling:")
    status = -1
    try
        status = run(`./print_args foo bar`)
    catch e
        @warn "Could not run $(scratch)/print_args"
        println(e)
    end
    @test isa(status, Base.Process)
    @test isa(status, Base.Process) && status.exitcode == 0
end

## --- Clean up

cd(testpath)
