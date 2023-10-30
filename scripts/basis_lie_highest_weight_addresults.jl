using Oscar

function main(args)
  @req length(args) == 3 "Need 3 arguments: \"A\", n, n_workers"
  @req args[1] == "A" "First argument must be \"A\""
  n = parse(Int, args[2])
  n_workers = parse(Int, args[3])

  output = MSet{Vector{Vector{ZZRingElem}}}()

  for worker_id in 1:n_workers
    path = "scripts/output_A_$(n)__$(n_workers)_$(worker_id).txt"
    @req isfile(path) "File $(path) does not exist"
    dict = eval(Meta.parse(read(path, String)))::Dict{Vector{Vector{ZZRingElem}},Int}
    output += MSet(dict)
  end

  open("scripts/output_A_$(n).txt", "w") do file
    print(file, output.dict)
  end
end

main(ARGS)
