struct MonomialBasis
  lie_algebra::LieAlgebraStructure
  # birational_sequence::BirationalSequence
  highest_weight::Vector{Int}
  monomial_ordering::MonomialOrdering
  dimension::Int
  monomials::Set{ZZMPolyRingElem}
  monomials_parent::ZZMPolyRing
  minkowski_gens::Vector{Vector{ZZRingElem}} # TODO: put in attribute storage
  birational_sequence::BirationalSequence # TODO: put in attribute storage

  function MonomialBasis(
    lie_algebra::LieAlgebraStructure,
    highest_weight::Vector{<:IntegerUnion},
    monomial_ordering::MonomialOrdering,
    monomials::Set{ZZMPolyRingElem},
    minkowski_gens::Vector{Vector{ZZRingElem}},
    birational_sequence::BirationalSequence,
  )
    return new(
      lie_algebra,
      Int.(highest_weight),
      monomial_ordering,
      length(monomials),
      monomials,
      parent(first(monomials)),
      minkowski_gens,
      birational_sequence,
    )
  end
end

base_lie_algebra(basis::MonomialBasis) = basis.lie_algebra

highest_weight(basis::MonomialBasis) = basis.highest_weight

dim(basis::MonomialBasis) = basis.dimension
length(basis::MonomialBasis) = dim(basis)

monomials(basis::MonomialBasis) = basis.monomials

monomial_ordering(basis::MonomialBasis) = basis.monomial_ordering

function Base.show(io::IO, ::MIME"text/plain", basis::MonomialBasis)
  io = pretty(io)
  println(io, "Monomial basis of a highest weight module")
  println(io, Indent(), "of highest weight $(highest_weight(basis))", Dedent())
  println(io, Indent(), "of dimension $(dim(basis))", Dedent())
  println(io, Indent(), "with monomial ordering $(monomial_ordering(basis))", Dedent())
  println(io, "over ", Lowercase(), base_lie_algebra(basis))
  print(
    io,
    Indent(),
    "where the birational sequence used consists of operators to the following weights (given as coefficients w.r.t. alpha_i):",
    Indent(),
  )
  for weight in basis.birational_sequence.weights_alpha
    print(io, '\n', Int.(weight))
  end
  println(io, Dedent(), Dedent())
  print(
    io,
    Indent(),
    "and the basis was generated by Minkowski sums of the bases of the following highest weight modules:",
    Indent(),
  )
  for gen in basis.minkowski_gens
    print(io, '\n', Int.(gen))
  end
  print(io, Dedent(), Dedent())
end

function Base.show(io::IO, basis::MonomialBasis)
  if get(io, :supercompact, false)
    print(io, "Monomial basis of a highest weight module")
  else
    print(
      io,
      "Monomial basis of a highest weight module with highest weight $(highest_weight(basis)) over ",
    )
    print(IOContext(io, :supercompact => true), base_lie_algebra(basis))
  end
end
