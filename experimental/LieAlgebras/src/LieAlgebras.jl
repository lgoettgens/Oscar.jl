isdefined(Oscar, :word) || function word end

module LieAlgebras

using ..Oscar

import Oscar: GAPWrap, IntegerUnion, MapHeader

import Random

# not importet in Oscar
using AbstractAlgebra:
  ProductIterator, _number_of_direct_product_factors, ordinal_number_string

using AbstractAlgebra.PrettyPrinting

# functions with new methods
import ..Oscar:
  _is_exterior_power,
  _is_tensor_product,
  _iso_oscar_gap,
  _vec,
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
  dot,
  dual,
  elem_type,
  expressify,
  exterior_power,
  gen,
  gens,
  height,
  hom,
  hom_direct_sum,
  hom_tensor,
  ideal,
  identity_map,
  image,
  induced_map_on_exterior_power,
  inv,
  is_abelian,
  is_finite,
  is_isomorphism,
  is_nilpotent,
  is_perfect,
  is_simple,
  is_solvable,
  is_welldefined,
  kernel,
  lower_central_series,
  matrix,
  normalizer,
  number_of_generators,
  ngens,
  order,
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

Oscar.@import_all_serialization_functions

import Base: getindex, deepcopy_internal, hash, issubset, iszero, parent, zero

export AbstractLieAlgebra, AbstractLieAlgebraElem
export DirectSumLieAlgebra, DirectSumLieAlgebraElem
export DualRootSpaceElem
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
export WeylOrbitIterator

export _is_direct_sum
export _is_dual
export _is_exterior_power
export _is_standard_module
export _is_symmetric_power
export _is_tensor_power
export _is_tensor_product
export abelian_lie_algebra
export abstract_module
export base_lie_algebra
export bilinear_form
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
export conjugate_dominant_weight_with_elem
export coroot
export coroots
export coxeter_matrix
export derived_algebra
export dim_of_simple_module
export dominant_character
export exterior_power
export fundamental_weight
export fundamental_weights
export general_linear_lie_algebra
export induced_map_on_symmetric_power
export induced_map_on_tensor_power
export is_cartan_matrix
export is_cartan_type
export is_coroot
export is_coroot_with_index
export is_dominant
export is_negative_coroot
export is_negative_coroot_with_index
export is_negative_root
export is_negative_root_with_index
export is_positive_coroot
export is_positive_coroot_with_index
export is_positive_root
export is_positive_root_with_index
export is_root
export is_root_with_index
export is_self_normalizing
export is_simple_coroot
export is_simple_coroot_with_index
export is_simple_root
export is_simple_root_with_index
export lie_algebra
export lmul, lmul!
export longest_element
export lower_central_series
export matrix_repr_basis
export multicombinations
export negative_coroot
export negative_coroots
export negative_root
export negative_roots
export number_of_positive_roots
export number_of_roots
export number_of_simple_roots
export permutations
export permutations_with_sign
export positive_coroot
export positive_coroots
export positive_root
export positive_roots
export reduced_expressions
export reflect, reflect!
export root_system, has_root_system
export root_system_type, has_root_system_type
export root_system_type_with_ordering
export show_dynkin_diagram
export simple_coroot
export simple_coroots
export simple_module
export simple_root
export simple_roots
export special_linear_lie_algebra
export special_orthogonal_lie_algebra
export standard_module
export symmetric_power
export symplectic_lie_algebra
export tensor_power
export tensor_product_decomposition
export trivial_module
export universal_enveloping_algebra
export weyl_group
export weyl_orbit
export word

function number_of_positive_roots end
function number_of_roots end
function number_of_simple_roots end

@alias n_positive_roots number_of_positive_roots
@alias n_roots number_of_roots
@alias n_simple_roots number_of_simple_roots

include("Types.jl")
include("Combinatorics.jl")
include("Util.jl")

include("CartanMatrix.jl")
include("CoxeterGroup.jl")
include("RootSystem.jl")
include("DynkinDiagram.jl")
include("WeylGroup.jl")

include("LieAlgebra.jl")
include("AbstractLieAlgebra.jl")
include("LinearLieAlgebra.jl")
include("DirectSumLieAlgebra.jl")

include("LieSubalgebra.jl")
include("LieAlgebraIdeal.jl")
include("LieAlgebraHom.jl")

include("LieAlgebraModule.jl")
include("LieAlgebraModuleHom.jl")

include("iso_oscar_gap.jl")
include("iso_gap_oscar.jl")
include("GapWrapper.jl")

include("serialization.jl")

end # module LieAlgebras

using .LieAlgebras

export AbstractLieAlgebra, AbstractLieAlgebraElem
export DirectSumLieAlgebra, DirectSumLieAlgebraElem
export DualRootSpaceElem
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
export WeylOrbitIterator

export abelian_lie_algebra
export abstract_module
export base_lie_algebra
export bilinear_form
export bracket
export cartan_bilinear_form
export cartan_matrix
export cartan_symmetrizer
export cartan_type
export cartan_type_with_ordering
export chevalley_basis
export coerce_to_lie_algebra_elem
export conjugate_dominant_weight
export conjugate_dominant_weight_with_elem
export coroot
export coroots
export coxeter_matrix
export derived_algebra
export dim_of_simple_module
export dominant_character
export exterior_power
export fundamental_weight
export fundamental_weights
export general_linear_lie_algebra
export induced_map_on_symmetric_power
export induced_map_on_tensor_power
export is_cartan_matrix
export is_cartan_type
export is_coroot
export is_coroot_with_index
export is_dominant
export is_negative_coroot
export is_negative_coroot_with_index
export is_negative_root
export is_negative_root_with_index
export is_positive_coroot
export is_positive_coroot_with_index
export is_positive_root
export is_positive_root_with_index
export is_root
export is_root_with_index
export is_self_normalizing
export is_simple_coroot
export is_simple_coroot_with_index
export is_simple_root
export is_simple_root_with_index
export lie_algebra
export lmul, lmul!
export longest_element
export lower_central_series
export matrix_repr_basis
export negative_coroot
export negative_coroots
export negative_root
export negative_roots
export number_of_positive_roots, n_positive_roots  # alias lives in a submodule
export number_of_roots, n_roots                    # alias lives in a submodule
export number_of_simple_roots, n_simple_roots      # alias lives in a submodule
export positive_coroot
export positive_coroots
export positive_root
export positive_roots
export reduced_expressions
export reflect, reflect!
export root
export root_system, has_root_system
export root_system_type, has_root_system_type
export root_system_type_with_ordering
export roots
export show_dynkin_diagram
export simple_coroot
export simple_coroots
export simple_module
export simple_root
export simple_roots
export special_linear_lie_algebra
export special_orthogonal_lie_algebra
export standard_module
export symmetric_power
export symplectic_lie_algebra
export tensor_power
export tensor_product_decomposition
export trivial_module
export universal_enveloping_algebra
export weyl_group
export weyl_orbit
export word
