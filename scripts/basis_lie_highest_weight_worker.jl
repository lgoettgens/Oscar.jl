using Oscar

@req length(ARGS) == 4 "Need 4 arguments: \"A\", n, n_workers, worker_id"
@req ARGS[1] == "A" "First argument must be \"A\""
n = parse(Int, ARGS[2])
n_workers = parse(Int, ARGS[3])
worker_id = parse(Int, ARGS[4])
@req 1 <= worker_id <= n_workers "worker_id must be between 1 and n_workers"

const printprefix = "Worker $(lpad(string(worker_id), ndigits(n_workers))):"

@info "$printprefix Oscar loaded..."

exprs = [
  Int.(el) for
  el in reduced_expressions(longest_element(weyl_group(:A, n)); up_to_commutation=true)
]

@info "$printprefix Reduced expressions calculated..."

output = MSet{Vector{Vector{ZZRingElem}}}()
inds = worker_id:n_workers:length(exprs)
for i in inds
  ret =
    BasisLieHighestWeight.basis_lie_highest_weight(
      :A, n, [1 for _ in 1:n], exprs[i]
    ).minkowski_gens
  @info "$printprefix $(i)/$(length(exprs))"
  push!(output, ret)
end
open("scripts/output_A_$(n)__$(n_workers)_$(worker_id).txt", "w") do file
  print(file, output.dict)
end
