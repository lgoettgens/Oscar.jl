using Oscar

function main(args)
  GC.enable_logging(true)
  @req length(args) == 4 "Need 4 arguments: \"A\", n, n_workers, worker_id"
  @req args[1] == "A" "First argument must be \"A\""
  n = parse(Int, args[2])
  n_workers = parse(Int, args[3])
  worker_id = parse(Int, args[4])
  @req 1 <= worker_id <= n_workers "worker_id must be between 1 and n_workers"

  printprefix = "Worker $(lpad(string(worker_id), ndigits(n_workers))):"

  @info "$printprefix Oscar loaded..."

  output = MSet{Vector{Vector{ZZRingElem}}}()
  for (i, expr) in enumerate(
    reduced_expressions(longest_element(weyl_group(:A, n)); up_to_commutation=true)
  )
    if ((i - 1) % n_workers) + 1 != worker_id
      continue
    end
    ret =
      BasisLieHighestWeight.basis_lie_highest_weight(
        :A, n, [1 for _ in 1:n], Int.(expr)
      ).minkowski_gens
    @info "$printprefix Task $(i)"
    push!(output, ret)
  end

  @info "$printprefix Finished, writing results..."

  open("scripts/output_A_$(n)__$(n_workers)_$(worker_id).txt", "w") do file
    print(file, output.dict)
  end

  @info "$printprefix Done."
end

main(ARGS)
