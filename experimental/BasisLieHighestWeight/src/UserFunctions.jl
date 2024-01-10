@doc raw"""
basis_coordinate_ring_kodaira(
  type::Symbol, rank::Int, highest_weight::Vector{Int}. degree::Int; monomial_ordering::Symbol=:degrevlex
)

Computes up the generators of the semi group of essential monomials with respecting to monomial_ordering of the Kodaira mapping 
of the generalized flag vaeriety of type and rank in the projective  space of the highest_weight module.
# Example
```jldoctest
julia> basis_coordinate_ring_kodaira(:G, 2, [1,1], 4; monomial_ordering = :invlex)
Generators of the semi group of essential monomials for the Kodaira embedding with
   the highest weight [1,1]
   up to degree 6
   with monomial ordering invlex
   for the Lie algebra of type G2
   and irational sequence consisting of the roots (given as coefficients w.r.t. alpha_i): 
   [1, 0]
   [0, 1]
   [1, 1]
   [2, 1]
   [3, 1]
   [3, 2]
then the numbers of generators added in each degree is
7  5  14  7  12  8 
"""

function basis_coordinate_ring_kodaira(
  type::Symbol, rank::Int, highest_weight::Vector{Int}, degree::Int; monomial_ordering::Symbol=:degrevlex
)
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = chevalley_basis[1] # TODO: change to [2]
  return basis_coordinate_ring_kodaira_compute(
    L, chevalley_basis, highest_weight, degree, operators, monomial_ordering
  )
end

function basis_coordinate_ring_kodaira(
  type::Symbol,
  rank::Int,
  highest_weight::Vector{Int},
  birational_sequence::Vector{Int},
  degree::Int;
  monomial_ordering::Symbol=:degrevlex,
)
L = lie_algebra(type, rank)
chevalley_basis = chevalley_basis_gap(L)
operators = operators_by_index(L, chevalley_basis, birational_sequence)
  return basis_coordinate_ring_kodaira_compute(
    L, chevalley_basis, highest_weight, degree, operators, monomial_ordering
  )
end

@doc raw"""
basis_coordinate_ring_kodaira_ffl(
  type::Symbol, rank::Int, highest_weight::Vector{Int}. degree::Int; monomial_ordering::Symbol=:degrevlex
)

Computes up the generators of the semi group of essential monomials with respecting to degrevlex of the Kodaira mapping 
of the generalized flag vaeriety of type and rank in the projective  space of the highest_weight module.
Here the ordering is a good ordering and the monomial ordering is degrevlex, so in type A and C, the monomial basis is the FFLV basis 
# Example
```jldoctest
julia> basis_coordinate_ring_kodaira(:G, 2, [1,1], 4; monomial_ordering = :invlex)
Generators of the semi group of essential monomials for the Kodaira embedding with
   the highest weight [1,1]
   up to degree 6
   with monomial ordering invlex
   for the Lie algebra of type G2
   and irational sequence consisting of the roots (given as coefficients w.r.t. alpha_i): 
   [1, 0]
   [0, 1]
   [1, 1]
   [2, 1]
   [3, 1]
   [3, 2]
then the numbers of generators added in each degree is
7  5  14  7  12  8 
"""


function basis_coordinate_ring_kodaira_ffl(
  type::Symbol, 
  rank::Int, 
  highest_weight::Vector{Int},
  degree::Int
  )
  monomial_ordering = :degrevlex
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = reverse(chevalley_basis[1]) # TODO: change to [2]
  #we reverse the order here to have simple roots at the right end, this is then a good ordering. Simple roots at the right end speed up the program very much
  return basis_coordinate_ring_kodaira_compute(
    L, chevalley_basis, highest_weight, degree, operators, monomial_ordering
  )
end

@doc raw"""
    basis_lie_highest_weight_operators(type::Symbol, rank::Int)

Lists the operators available for a given simple Lie algebra of type `type_rank`,
together with their index.
Operators $f_\alpha$ of negative roots are shown as the coefficients of the corresponding positive root.
w.r.t. the simple roots $\alpha_i$.

# Example
```jldoctest
julia> basis_lie_highest_weight_operators(:B, 2)
4-element Vector{Tuple{Int64, Vector{QQFieldElem}}}:
 (1, [1, 0])
 (2, [0, 1])
 (3, [1, 1])
 (4, [1, 2])
```
"""
function basis_lie_highest_weight_operators(type::Symbol, rank::Int)
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = chevalley_basis[1]  # TODO: change to [2]
  weights_alpha = [w_to_alpha(L, weight(L, op)) for op in operators]
  return collect(enumerate(weights_alpha))
end

@doc raw"""
    basis_lie_highest_weight(type::Symbol, rank::Int, highest_weight::Vector{Int}; monomial_ordering::Symbol=:degrevlex)
    basis_lie_highest_weight(type::Symbol, rank::Int, highest_weight::Vector{Int}, birational_sequence::Vector{Int}; monomial_ordering::Symbol=:degrevlex)
    basis_lie_highest_weight(type::Symbol, rank::Int, highest_weight::Vector{Int}, birational_sequence::Vector{Vector{Int}}; monomial_ordering::Symbol=:degrevlex)

Computes a monomial basis for the highest weight module with highest weight
`highest_weight` (in terms of the fundamental weights $\omega_i$),
for a simple Lie algebra of type `type_rank`.

If no birational sequence is specified, all operators in the order of `basis_lie_highest_weight_operators` are used.
A birational sequence of type `Vector{Int}` is a sequence of indices of operators in `basis_lie_highest_weight_operators`.
A birational sequence of type `Vector{Vector{Int}}` is a sequence of weights in terms of the simple roots $\alpha_i$.

`monomial_ordering` describes the monomial ordering used for the basis.
If this is a weighted ordering, the height of the corresponding root is used as weight.

# Examples
```jldoctest
julia> base = basis_lie_highest_weight(:A, 2, [1, 1])
Monomial basis of a highest weight module
  of highest weight [1, 1]
  of dimension 8
  with monomial ordering degrevlex([x1, x2, x3])
over Lie algebra of type A2
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 0]
    [0, 1]
    [1, 1]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0]
    [0, 1]

julia> base = basis_lie_highest_weight(:A, 3, [2, 2, 3]; monomial_ordering = :lex)
Monomial basis of a highest weight module
  of highest weight [2, 2, 3]
  of dimension 1260
  with monomial ordering lex([x1, x2, x3, x4, x5, x6])
over Lie algebra of type A3
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
    [1, 1, 0]
    [0, 1, 1]
    [1, 1, 1]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]

julia> base = basis_lie_highest_weight(:A, 2, [1, 0], [1,2,1])
Monomial basis of a highest weight module
  of highest weight [1, 0]
  of dimension 3
  with monomial ordering degrevlex([x1, x2, x3])
over Lie algebra of type A2
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 0]
    [0, 1]
    [1, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0]

julia> base = basis_lie_highest_weight(:A, 2, [1, 0], [[1,0], [0,1], [1,0]])
Monomial basis of a highest weight module
  of highest weight [1, 0]
  of dimension 3
  with monomial ordering degrevlex([x1, x2, x3])
over Lie algebra of type A2
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 0]
    [0, 1]
    [1, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0]

julia> base = basis_lie_highest_weight(:C, 3, [1, 1, 1]; monomial_ordering = :lex)
Monomial basis of a highest weight module
  of highest weight [1, 1, 1]
  of dimension 512
  with monomial ordering lex([x1, x2, x3, x4, x5, x6, x7, x8, x9])
over Lie algebra of type C3
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
    [1, 1, 0]
    [0, 1, 1]
    [1, 1, 1]
    [0, 2, 1]
    [1, 2, 1]
    [2, 2, 1]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
    [0, 1, 1]
    [1, 1, 1]
```
"""
function basis_lie_highest_weight(
  type::Symbol, rank::Int, highest_weight::Vector{Int}; monomial_ordering::Symbol=:degrevlex
)
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = reverse(chevalley_basis[1]) # TODO: change to [2]
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

function basis_lie_highest_weight(
  type::Symbol,
  rank::Int,
  highest_weight::Vector{Int},
  birational_sequence::Vector{Int};
  monomial_ordering::Symbol=:degrevlex,
)
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = operators_by_index(L, chevalley_basis, birational_sequence)
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

function basis_lie_highest_weight(
  type::Symbol,
  rank::Int,
  highest_weight::Vector{Int},
  birational_sequence::Vector{Vector{Int}};
  monomial_ordering::Symbol=:degrevlex,
)
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = operators_by_simple_roots(L, chevalley_basis, birational_sequence)
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

@doc raw"""
    basis_lie_highest_weight_lusztig(type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int})

Computes a monomial basis for the highest weight module with highest weight
`highest_weight` (in terms of the fundamental weights $\omega_i$),
for a simple Lie algebra $L$ of type `type_rank`.

Let $\omega_0 = s_{i_1} \cdots s_{i_N}$ be a reduced expression of the longest element in the Weyl group of $L$
given as indices $[i_1, \dots, i_N]$ in `reduced_expression`.
Then the birational sequence used consists of $\beta_1, \dots, \beta_N$ where $\beta_1 := \alpha_{i_1}$ and \beta_k := s_{i_1} \cdots s_{i_{k-1}} \alpha_{i_k}$ for $k = 2, \dots, N$.

The monomial ordering is fixed to `wdegrevlex` (weighted degree reverse lexicographic order).

# Examples
```jldoctest
julia> base = basis_lie_highest_weight_lusztig(:D, 4, [1,1,1,1], [4,3,2,4,3,2,1,2,4,3,2,1])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1, 1]
  of dimension 4096
  with monomial ordering wdegrevlex([x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12], [1, 1, 3, 2, 2, 1, 5, 4, 3, 3, 2, 1])
over Lie algebra of type D4
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [0, 0, 0, 1]
    [0, 0, 1, 0]
    [0, 1, 1, 1]
    [0, 1, 1, 0]
    [0, 1, 0, 1]
    [0, 1, 0, 0]
    [1, 2, 1, 1]
    [1, 1, 1, 1]
    [1, 1, 0, 1]
    [1, 1, 1, 0]
    [1, 1, 0, 0]
    [1, 0, 0, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
    [0, 0, 0, 1]
    [0, 0, 1, 1]
```
"""
function basis_lie_highest_weight_lusztig(
  type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int}
)
  monomial_ordering = :wdegrevlex
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = operators_lusztig(L, chevalley_basis, reduced_expression)
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

@doc raw"""
    basis_lie_highest_weight_string(type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int})

Computes a monomial basis for the highest weight module with highest weight
`highest_weight` (in terms of the fundamental weights $\omega_i$),
for a simple Lie algebra $L$ of type `type_rank`.

Let $\omega_0 = s_{i_1} \cdots s_{i_N}$ be a reduced expression of the longest element in the Weyl group of $L$
given as indices $[i_1, \dots, i_N]$ in `reduced_expression`.
Then the birational sequence used consists of $\alpha_{i_1}, \dots, \alpha_{i_N}$.

The monomial ordering is fixed to `neglex` (negative lexicographic order).      

# Examples
```jldoctest
julia> basis_lie_highest_weight_string(:B, 3, [1,1,1], [3,2,3,2,1,2,3,2,1])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1]
  of dimension 512
  with monomial ordering neglex([x1, x2, x3, x4, x5, x6, x7, x8, x9])
over Lie algebra of type B3
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [0, 0, 1]
    [0, 1, 0]
    [0, 0, 1]
    [0, 1, 0]
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
    [0, 1, 0]
    [1, 0, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]

julia> basis_lie_highest_weight_string(:A, 4, [1,1,1,1], [4,3,2,1,2,3,4,3,2,3])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1, 1]
  of dimension 1024
  with monomial ordering neglex([x1, x2, x3, x4, x5, x6, x7, x8, x9, x10])
over Lie algebra of type A4
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [0, 0, 0, 1]
    [0, 0, 1, 0]
    [0, 1, 0, 0]
    [1, 0, 0, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
    [0, 0, 0, 1]
    [0, 0, 1, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
    [0, 0, 0, 1]
    [0, 1, 0, 1]
```
"""
function basis_lie_highest_weight_string(
  type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int}
)
  monomial_ordering = :neglex
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = operators_by_index(L, chevalley_basis, reduced_expression)
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

@doc raw"""
    basis_lie_highest_weight_pbw(type::Symbol, rank::Int, highest_weight::Vector{Int})

Computes a monomial basis for the highest weight module with highest weight
`highest_weight` (in terms of the fundamental weights $\omega_i$),
for a simple Lie algebra $L$ of type `type_rank`.

Then the birational sequence used consists of all operators in descening height of the corresponding root.

The monomial ordering is fixed to `neglex` (negative lexicographic order).      
      
# Examples
```jldoctest
julia> basis_lie_highest_weight_pbw(:A, 3, [1,1,1])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1]
  of dimension 64
  with monomial ordering degrevlex([x1, x2, x3, x4, x5, x6])
over Lie algebra of type A3
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [1, 1, 1]
    [0, 1, 1]
    [1, 1, 0]
    [0, 0, 1]
    [0, 1, 0]
    [1, 0, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
```
"""
function basis_lie_highest_weight_pbw(type::Symbol, rank::Int, highest_weight::Vector{Int})
  monomial_ordering = :degrevlex
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = reverse(chevalley_basis[1]) # TODO: change to [2]
  #we reverse the order here to have simple roots at the right end, this is then a good ordering. Simple roots at the right end speed up the program very much
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end

@doc raw"""
    basis_lie_highest_weight_nz(type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int})

Computes a monomial basis for the highest weight module with highest weight
`highest_weight` (in terms of the fundamental weights $\omega_i$),
for a simple Lie algebra $L$ of type `type_rank`.

Let $\omega_0 = s_{i_1} \cdots s_{i_N}$ be a reduced expression of the longest element in the Weyl group of $L$
given as indices $[i_1, \dots, i_N]$ in `reduced_expression`.
Then the birational sequence used consists of $\alpha_{i_1}, \dots, \alpha_{i_N}$.

The monomial ordering is fixed to `degrevlex` (degree reverse lexicographic order).      

# Examples
```jldoctest
julia> basis_lie_highest_weight_nz(:C, 3, [1,1,1], [3,2,3,2,1,2,3,2,1])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1]
  of dimension 512
  with monomial ordering degrevlex([x1, x2, x3, x4, x5, x6, x7, x8, x9])
over Lie algebra of type C3
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [0, 0, 1]
    [0, 1, 0]
    [0, 0, 1]
    [0, 1, 0]
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]
    [0, 1, 0]
    [1, 0, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0]
    [0, 1, 0]
    [0, 0, 1]

julia> basis_lie_highest_weight_nz(:A, 4, [1,1,1,1], [4,3,2,1,2,3,4,3,2,3])
Monomial basis of a highest weight module
  of highest weight [1, 1, 1, 1]
  of dimension 1024
  with monomial ordering degrevlex([x1, x2, x3, x4, x5, x6, x7, x8, x9, x10])
over Lie algebra of type A4
  where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):
    [0, 0, 0, 1]
    [0, 0, 1, 0]
    [0, 1, 0, 0]
    [1, 0, 0, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
    [0, 0, 0, 1]
    [0, 0, 1, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
  and the basis was generated by Minkowski sums of the bases of the following highest weight modules:
    [1, 0, 0, 0]
    [0, 1, 0, 0]
    [0, 0, 1, 0]
    [0, 0, 0, 1]
    [0, 1, 0, 1] 
```
"""
function basis_lie_highest_weight_nz(
  type::Symbol, rank::Int, highest_weight::Vector{Int}, reduced_expression::Vector{Int}
)
  monomial_ordering = :degrevlex
  L = lie_algebra(type, rank)
  chevalley_basis = chevalley_basis_gap(L)
  operators = operators_by_index(L, chevalley_basis, reduced_expression)
  return basis_lie_highest_weight_compute(
    L, chevalley_basis, highest_weight, operators, monomial_ordering
  )
end
