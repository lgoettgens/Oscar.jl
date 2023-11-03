using Oscar

function main(args)
  @req length(args) == 2 "Need 2 arguments: \"A\", n"
  @req args[1] == "A" "First argument must be \"A\""
  n = parse(Int, args[2])

  path = "scripts/output/A_$(n)"

  output = MSet{Vector{Vector{ZZRingElem}}}()

  for (i, expr) in enumerate(
    reduced_expressions(longest_element(weyl_group(:A, n)); up_to_commutation=true)
  )
    filename = joinpath(path, "$(i).txt")
    isfile(filename) || error("File $filename does not exist")

    entry = eval(Meta.parse(read(filename, String)))::Vector{Vector{ZZRingElem}}
    push!(output, entry)
  end

  open(joinpath(dirname(path), "A_$(n).txt"), "w") do file
    print(file, output.dict)
  end
end

main(ARGS)
