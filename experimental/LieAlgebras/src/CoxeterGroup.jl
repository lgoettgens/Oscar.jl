function is_coxeter_matrix(M::ZZMatrix)
  @req is_square(M) "matrix must be square"
  is_symmetric(M) || return false
  for i in 1:nrows(M), j in i:ncols(M)
    entry = M[i, j]
    if i == j
      is_one(entry) || return false
    else
      is_zero(entry) || entry >= 2 || return false
    end
  end
  return true
end

@doc raw"""
    coxeter_matrix_from_cartan_matrix(gcm::ZZMatrix; check::Bool=true) -> Bool

Return the Coxeter matrix $m$ associated to the Cartan matrix `gcm`. If there is no relation between $i$ and $j$,
then this will be expressed by $m_{ij} = 0$ (instead of the usual convention $m_{ij} = \infty$).
The keyword argument `check` can be set to `false` to skip verification whether `gcm` is indeed a generalized Cartan matrix.
"""
function coxeter_matrix_from_cartan_matrix(gcm::ZZMatrix; check::Bool=true)
  check && @req is_cartan_matrix(gcm) "requires a generalized Cartan matrix"

  rk, _ = size(gcm)
  cm = matrix(
    ZZ, [coxeter_matrix_entry_from_cartan_matrix(gcm, i, j) for i in 1:rk, j in 1:rk]
  )

  return cm
end

function coxeter_matrix_entry_from_cartan_matrix(gcm::ZZMatrix, ij::Tuple{Int, Int})
  return coxeter_matrix_entry_from_cartan_matrix(gcm, ij...)
end

function coxeter_matrix_entry_from_cartan_matrix(gcm::ZZMatrix, i::Int, j::Int)
  if i == j
    return 1
  end

  d = gcm[i, j] * gcm[j, i]
  if d == 0
    return 2
  elseif d == 1
    return 3
  elseif d == 2
    return 4
  elseif d == 3
    return 6
  else
    return 0
  end
end

function _coxeter_group(::Type{FPGroup}, rk::Int, cox_mat_entry_getter)
  F = free_group(rk)

  rels = [(gen(F, i) * gen(F, j))^cox_mat_entry_getter(i, j) for i in 1:rk for j in i:rk]
  G, _ = quo(F, rels)
  return G
end

function coxeter_group(::Type{FPGroup}, cox_mat::ZZMatrix; check::Bool=true)
  @req is_symmetric(M) "matrix must be symmetric"
  check && @req is_coxeter_matrix(cox_mat) "requires a Coxeter matrix"
  rk = nrows(cox_mat)
  return _coxeter_group(FPGroup, rk, Fix1(getindex, cox_mat) ∘ CartesianIndex)
end
