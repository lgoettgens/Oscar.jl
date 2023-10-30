function main(args)
  length(args) == 3 || error("Need 3 arguments: \"A\", n, n_workers")
  args[1] == "A" || error("First argument must be \"A\"")
  n = parse(Int, args[2])
  n_workers = parse(Int, args[3])

  workers = []

  for worker_id in 1:n_workers
    worker = run(
      `$(Base.julia_cmd()) --project=. scripts/basis_lie_highest_weight_worker.jl $(args[1]) $(args[2]) $(args[3]) $(worker_id)`,
      stdin,
      stdout,
      stderr;
      wait=false,
    )
    push!(workers, worker)
  end

  all(success, workers) || error("At least one worker failed")
  @info "All workers finished, collecting results..."

  run(
    `$(Base.julia_cmd()) --project=. scripts/basis_lie_highest_weight_addresults.jl $(args[1]) $(args[2]) $(args[3])`,
    stdin,
    stdout,
    stderr;
    wait=true,
  )
end

main(ARGS)
