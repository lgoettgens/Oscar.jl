using Oscar

function main(args)
  @req length(args) == 4 "Need 4 arguments: \"A\", n, n_workers, worker_id"
  @req args[1] == "A" "First argument must be \"A\""
  n = parse(Int, args[2])
  n_workers = parse(Int, args[3])
  worker_id = parse(Int, args[4])
  @req 1 <= worker_id <= n_workers "worker_id must be between 1 and n_workers"

  printprefix = "Worker $(lpad(string(worker_id), ndigits(n_workers))):"

  @info "$printprefix Oscar loaded..."

  path = "scripts/output/A_$(n)"
  mkpath(path)

  for (i, expr) in enumerate(
    reduced_expressions(longest_element(weyl_group(:A, n)); up_to_commutation=true)
  )
    if ((i - 1) % n_workers) + 1 != worker_id
      continue
    end
    filename = joinpath(path, "$(i).txt")
    if isfile(filename)
      @info "$printprefix File $filename already exists, skipping..."
      continue
    end
    ret =
      BasisLieHighestWeight.basis_lie_highest_weight(
        :A, n, [1 for _ in 1:n], Int.(expr)
      ).minkowski_gens
    open(filename, "w") do file
      print(file, ret)
    end
    @info "$printprefix Task $(i)"
  end

  @info "$printprefix Done."
end

main(ARGS)
