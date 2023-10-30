using Oscar

@req length(ARGS) == 3 "Need 3 arguments: \"A\", n, n_workers"
@req ARGS[1] == "A" "First argument must be \"A\""
n = parse(Int, ARGS[2])
n_workers = parse(Int, ARGS[3])

output = MSet{Vector{Vector{ZZRingElem}}}()

for worker_id in 1:n_workers
  global output
  path = "scripts/output_A_$(n)__$(n_workers)_$(worker_id).txt"
  @req isfile(path) "File $(path) does not exist"
  dict = eval(Meta.parse(read(path, String)))::Dict{Vector{Vector{ZZRingElem}},Int}
  output += MSet(dict)
end

open("scripts/output_A_$(n).txt", "w") do file
  print(file, output.dict)
end
