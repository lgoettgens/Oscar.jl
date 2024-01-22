function weight end
function word end

module LieAlgebras

using ..Oscar

import Oscar: GAPWrap, IntegerUnion, MapHeader

# not importet in Oscar
using AbstractAlgebra: CacheDictType, ProductIterator, get_cached!, ordinal_number_string

using AbstractAlgebra.PrettyPrinting

# functions with new methods
import ..Oscar:
  _iso_oscar_gap,
  action,
  basis_matrix,
  basis,
  canonical_injection,
  canonical_injections,
  canonical_projection,
  canonical_projections,
  center,
  centralizer,
  character,
  characteristic,
  coeff,
  coefficient_ring,
  coefficients,
  compose,
  derived_series,
  dim,
  direct_sum,
  dual,
  elem_type,
  expressify,
  exterior_power,
  gen,
  gens,
  hom,
  hom_tensor,
  ideal,
  identity_map,
  image,
  induced_map_on_exterior_power,
  inv,
  is_abelian,
  is_exterior_power,
  is_isomorphism,
  is_nilpotent,
  is_perfect,
  is_simple,
  is_solvable,
  is_tensor_product,
  is_welldefined,
  kernel,
  lower_central_series,
  matrix,
  ngens,
  normalizer,
  parent_type,
  rank,
  root,
  roots,
  sub,
  symbols,
  symmetric_power,
  tensor_product,
  weyl_vector,
  word,
  zero_map,
  ⊕,
  ⊗

import Base: getindex, deepcopy_internal, hash, issubset, iszero, parent, zero

export AbstractLieAlgebra, AbstractLieAlgebraElem
export LieAlgebra, LieAlgebraElem
export LieAlgebraHom
export LieAlgebraIdeal
export LieAlgebraModule, LieAlgebraModuleElem
export LieAlgebraModuleHom
export LieSubalgebra
export LinearLieAlgebra, LinearLieAlgebraElem
export RootSpaceElem
export RootSystem
export WeightLatticeElem
export WeylGroup, WeylGroupElem

export abelian_lie_algebra
export abstract_module
export base_lie_algebra
export bracket
export cartan_bilinear_form
export cartan_matrix
export cartan_symmetrizer
export cartan_type
export cartan_type_with_ordering
export chevalley_basis
export coefficient_vector
export coerce_to_lie_algebra_elem
export combinations
export conjugate_dominant_weight
export coxeter_matrix
export derived_algebra
export dim_of_simple_module
export dominant_character
export exterior_power
export fundamental_weight
export fundamental_weights
export general_linear_lie_algebra
export hom_direct_sum
export induced_map_on_symmetric_power
export induced_map_on_tensor_power
export is_cartan_matrix
export is_cartan_type
export is_direct_sum
export is_dual
export is_negative_root_with_index
export is_positive_root_with_index
export is_root_with_index
export is_self_normalizing
export is_simple_root_with_index
export is_standard_module
export is_symmetric_power
export is_tensor_power
export lie_algebra
export lmul!
export longest_element
export lower_central_series
export matrix_repr_basis
export multicombinations
export negative_root
export negative_roots
export num_positive_roots
export num_roots, nroots
export num_simple_roots
export permutations
export permutations_with_sign
export positive_root
export positive_roots
export reduced_expressions
export reflect, reflect!
export root_system_type, has_root_system_type
export root_system, has_root_system
export show_dynkin_diagram
export simple_module
export simple_root
export simple_roots
export special_linear_lie_algebra
export special_orthogonal_lie_algebra
export standard_module
export symmetric_power
export tensor_power
export tensor_product_decomposition
export trivial_module
export universal_enveloping_algebra
export weyl_group
export word

include("Combinatorics.jl")
include("CartanMatrix.jl")
include("CoxeterGroup.jl")
include("RootSystem.jl")
include("DynkinDiagram.jl")
include("WeylGroup.jl")

include("Util.jl")
include("LieAlgebra.jl")
include("AbstractLieAlgebra.jl")
include("LinearLieAlgebra.jl")
include("LieSubalgebra.jl")
include("LieAlgebraIdeal.jl")
include("LieAlgebraHom.jl")
include("LieAlgebraModule.jl")
include("LieAlgebraModuleHom.jl")
include("iso_oscar_gap.jl")
include("iso_gap_oscar.jl")
include("GapWrapper.jl")

end

using .LieAlgebras

export AbstractLieAlgebra, AbstractLieAlgebraElem
export LieAlgebra, LieAlgebraElem
export LieAlgebraHom
export LieAlgebraIdeal
export LieAlgebraModule, LieAlgebraModuleElem
export LieAlgebraModuleHom
export LieSubalgebra
export LinearLieAlgebra, LinearLieAlgebraElem
export RootSpaceElem
export RootSystem
export WeightLatticeElem
export WeylGroup, WeylGroupElem

export abelian_lie_algebra
export abstract_module
export base_lie_algebra
export bracket
export cartan_bilinear_form
export cartan_matrix
export cartan_symmetrizer
export cartan_type
export cartan_type_with_ordering
export chevalley_basis
export coerce_to_lie_algebra_elem
export conjugate_dominant_weight
export coxeter_matrix
export derived_algebra
export dim_of_simple_module
export dominant_character
export exterior_power
export fundamental_weight
export fundamental_weights
export general_linear_lie_algebra
export hom_direct_sum
export induced_map_on_symmetric_power
export induced_map_on_tensor_power
export is_cartan_matrix
export is_cartan_type
export is_direct_sum
export is_dual
export is_negative_root_with_index
export is_positive_root_with_index
export is_root_with_index
export is_self_normalizing
export is_simple_root_with_index
export is_standard_module
export is_symmetric_power
export is_tensor_power
export is_tensor_product
export lie_algebra
export lmul!
export longest_element
export lower_central_series
export matrix_repr_basis
export matrix_repr_basis
export negative_root
export negative_roots
export num_positive_roots
export num_roots, nroots
export num_simple_roots
export positive_root
export positive_roots
export reduced_expressions
export reflect, reflect!
export root
export root_system_type, has_root_system_type
export root_system, has_root_system
export roots
export show_dynkin_diagram
export simple_module
export simple_root
export simple_roots
export special_linear_lie_algebra
export special_orthogonal_lie_algebra
export standard_module
export symmetric_power
export tensor_power
export tensor_product_decomposition
export trivial_module
export universal_enveloping_algebra
export weyl_group
export word

function part_c_cartan_matrix()
  cm = cartan_matrix((:A, 3), (:E, 8), (:C, 8), (:E, 6), (:B, 3))
  for (i, j) in [
    (19, 27),
    (27, 6),
    (10, 3),
    (18, 22),
    (20, 9),
    (13, 27),
    (22, 21),
    (21, 3),
    (22, 24),
    (23, 2),
    (19, 19),
    (22, 26),
    (12, 10),
    (3, 24),
    (26, 19),
    (10, 10),
    (20, 27),
    (5, 11),
    (16, 2),
    (12, 4),
    (16, 14),
    (7, 7),
    (13, 9),
    (18, 1),
    (18, 10),
    (16, 19),
    (9, 9),
    (20, 7),
    (13, 5),
    (1, 1),
    (9, 5),
    (12, 3),
    (10, 5),
    (22, 2),
    (1, 25),
    (24, 17),
    (1, 13),
    (6, 6),
    (18, 10),
    (20, 24),
  ]
    swap_cols!(cm, i, j)
    swap_rows!(cm, i, j)
  end
  return cm
end

function part_d_cartan_matrix()
  cm = cartan_matrix((:A, 5), (:B, 3), (:B, 3), (:G, 2), (:E, 8), (:D, 13))
  for (i, j) in [
    (18, 34),
    (27, 9),
    (34, 24),
    (12, 15),
    (5, 17),
    (2, 11),
    (18, 16),
    (2, 19),
    (13, 20),
    (9, 33),
    (9, 6),
    (20, 6),
    (25, 31),
    (8, 25),
    (30, 8),
    (26, 14),
    (31, 33),
    (31, 3),
    (10, 27),
    (3, 21),
    (30, 1),
    (1, 3),
    (25, 1),
    (31, 11),
    (11, 12),
    (6, 28),
    (28, 25),
    (31, 22),
    (3, 23),
    (34, 31),
    (1, 8),
    (13, 31),
    (1, 11),
    (26, 22),
    (9, 17),
    (13, 27),
    (24, 13),
    (31, 26),
    (6, 1),
    (25, 8),
    (1, 30),
    (16, 31),
    (9, 29),
    (1, 2),
    (17, 6),
    (25, 1),
    (11, 21),
    (1, 28),
    (17, 9),
    (32, 14),
  ]
    swap_cols!(cm, i, j)
    swap_rows!(cm, i, j)
  end
  return cm
end

function conjugate_to_fundamental_chamber_with_elem(x::RootSpaceElem)
  conj = deepcopy(x)
  cm = sparse_matrix(QQMatrix(cartan_matrix(root_system(x))))
  word = Int[]
  s = 1
  while s <= rank(root_system(x))
    if (cm * transpose(conj.vec))[s] < 0
      push!(word, s)
      reflect!(conj, s)
      s = 1
    else
      s += 1
    end
  end
  return conj, WeylGroupElem(root_system(x), reverse(word))
end

export conjugate_to_fundamental_chamber_with_elem
export part_c_cartan_matrix
export part_d_cartan_matrix
