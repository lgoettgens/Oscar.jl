#This code uses Derksen's algorithm to compute fundamental invariants of linearly reductive group.
#We first set up LinearlyReductiveGroup , then we set up a representation via which the group acts on a vector space (RepresentationLinearlyReductiveGroup)
#Then we set up the invariant ring of the group. The fundamental invariants are computed using Derksen's alg.
#As of now, the only reynolds operator that is implemented is the one for SLm, using Cayley's Omega process.

export canonical_representation
export group_ideal
export LinearlyReductiveGroup
export linearly_reductive_group
export natural_representation
export null_cone_ideal
export RedGroupInvarRing
export representation
export RepresentationLinearlyReductiveGroup
export representation_matrix
export representation_reductive_group
export representation_on_forms
export tensor

##########################
#Setting up Reductive Groups 
##########################
#These are objects that carry information about a linearly reductive group. 
#As of now it is only implemented for SLn, its direct products and tensors. 

mutable struct LinearlyReductiveGroup
    field::Field #characteristic zero. implement check? 
    group::Tuple{Symbol, Int}
    group_ideal::MPolyIdeal
    reynolds_operator::Function
    canonical_representation::MatElem

    function LinearlyReductiveGroup(sym::Symbol, m::Int, fld::Field) #have not decided the representation yet
        #check char(fld)
        @assert sym == :SL && characteristic(fld) == 0
        R, _ = polynomial_ring(fld, :z => (1:m,1:m))
        return LinearlyReductiveGroup(sym, m, R)
    end

    function LinearlyReductiveGroup(sym::Symbol, m::Int, pring::MPolyRing) #the ring input is the group ring
        #check char(field)
        G = new()
        fld = base_ring(pring)
        @assert sym == :SL  && characteristic(fld) == 0 
        characteristic(fld) == 0 || error("Characteristic should be 0 for linearly reductive groups")
        G.field = fld
        @req m^2  == ngens(pring) "ring not compatible"
        G.group = (sym,m)
        G.reynolds_operator = reynolds_slm
        M = transpose(matrix(pring, m, m, gens(pring)))
        G.canonical_representation = M
        G.group_ideal = ideal([det(M) - 1])
        #base ring of M has to be the same as the representation matrix when that is created later.
        return G
    end
end

function Base.show(io::IO, G::LinearlyReductiveGroup)
    io = pretty(io)
    if G.group[1] == :SL
        println(io, "Reductive group ", G.group[1], G.group[2])
        print(IOContext(io, :supercompact => true), Indent(), "over ", Lowercase(), field(G))
        print(io, Dedent())
    end
end

#getter functions

@doc raw"""
    linearly_reductive_group(sym::Symbol, m::Int, K::Field)

Return the linearly reductive group indicated by `sym`.

Currently, the supported options for `sym` are:
* `:SL`, corresponding to the special linear group (of degree $m$ over the field $K$).

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 2, QQ)
Reductive group SL2
  over QQ

julia> group_ideal(G)
Ideal generated by
  z[1, 1]*z[2, 2] - z[2, 1]*z[1, 2] - 1
```
"""
linearly_reductive_group(sym::Symbol, m::Int, F::Field) =  LinearlyReductiveGroup(sym,m,F)

@doc raw"""
    linearly_reductive_group(sym::Symbol, m::Int, R::MPolyRing)

Return the linearly reductive group indicated by `sym`.

Currently, the supported options for `sym` are:
* `:SL`, corresponding to the special linear group (of degree $m$ over the base field $K$ of $R$, where $R$ is the polynomial ring in which the defining ideal of SL$(m, K)$ lives).

# Examples
```jldoctest
julia> S, z = polynomial_ring(QQ, "c"=> (1:2, 1:2));

julia> G = linearly_reductive_group(:SL,2,S)
Reductive group SL2
  over QQ

julia> group_ideal(G)
Ideal generated by
  c[1, 1]*c[2, 2] - c[2, 1]*c[1, 2] - 1
```
"""
linearly_reductive_group(sym::Symbol, m::Int, R::MPolyRing) = LinearlyReductiveGroup(sym,m,R)

group(G::LinearlyReductiveGroup) = G.group
field(G::LinearlyReductiveGroup) = G.field
reynolds_operator(G::LinearlyReductiveGroup) = G.reynolds_operator
group_ideal(G::LinearlyReductiveGroup) = G.group_ideal
canonical_representation(G::LinearlyReductiveGroup) = G.canonical_representation
natural_representation(G::LinearlyReductiveGroup) = G.canonical_representation

#####################
#Setting up Representation objects
#####################
#Objects of type LinearlyReductiveGroup can be embedded in GLn (for some n) via a representation. This defines the action on a vector space. 
#We set up an object RepresentationLinearlyReductiveGroup that carries information about this representation.

mutable struct RepresentationLinearlyReductiveGroup
    group::LinearlyReductiveGroup
    rep_mat::MatElem
    reynolds_v::Function

    #stores if the representation is on symmetric forms, and of which degree. 
    sym_deg::Tuple{Bool, Int}
    
    
    #representation of group G over symmetric degree d
    function RepresentationLinearlyReductiveGroup(G::LinearlyReductiveGroup, d::Int)
        R = new()
        R.group = G
        R.rep_mat = rep_mat_(G, d)
        R.sym_deg = (true, d)
        R.reynolds_v = reynolds_v_slm
        return R
    end
    
    #matrix M is the representation matrix. does not check M.
    function RepresentationLinearlyReductiveGroup(G::LinearlyReductiveGroup, M::MatElem)
        @req base_ring(M) == base_ring(G.group_ideal) "Group ideal and representation matrix must have same parent ring"
        R = new()
        R.group = G
        R.rep_mat = M
        R.sym_deg = (false, 0)
        R.reynolds_v = reynolds_v_slm
        return R
    end
end

representation_reductive_group(G::LinearlyReductiveGroup, M::MatElem) = RepresentationLinearlyReductiveGroup(G,M)
group(R::RepresentationLinearlyReductiveGroup) = R.group
representation_matrix(R::RepresentationLinearlyReductiveGroup) = R.rep_mat
vector_space_dimension(R::RepresentationLinearlyReductiveGroup) = ncols(R.rep_mat)

@doc raw"""
    representation_on_forms(G::LinearlyReductiveGroup, d::Int)

If `G` is the special linear group acting by linear substitution on, say, `n`-ary forms of degree `d`, return the corresponding representation.

!!! note
    In accordance with classical papers, an $n$-ary form of degree $d$ in $K[x_1, \dots, x_n]$ is written as a $K$-linear combination
    of the $K$-basis with elements $\binom{n}{I}x^I$. Here, $I = (i_1, \dots, i_n)\in\mathbb Z_{\geq 0}^n$ with $i_1+\dots +i_n =d$.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 2, QQ);

julia> r = representation_on_forms(G, 2)
Representation of SL2
  on symmetric forms of degree 2

julia> representation_matrix(r)
[      z[1, 1]^2                   2*z[1, 1]*z[2, 1]         z[2, 1]^2]
[z[1, 1]*z[1, 2]   z[1, 1]*z[2, 2] + z[2, 1]*z[1, 2]   z[2, 1]*z[2, 2]]
[      z[1, 2]^2                   2*z[1, 2]*z[2, 2]         z[2, 2]^2]
```
"""
function representation_on_forms(G::LinearlyReductiveGroup, d::Int)
    @assert G.group[1] == :SL
    return RepresentationLinearlyReductiveGroup(G, d)
end

function representation_reductive_group(G::LinearlyReductiveGroup)
    @assert G.group[1] == :SL
    M = canonical_representation(G)
    return RepresentationLinearlyReductiveGroup(G,M)
end

function Base.show(io::IO, R::RepresentationLinearlyReductiveGroup)
    io = pretty(io)
    @assert group(group(R))[1] == :SL
    println(io, "Representation of ", group(group(R))[1], group(group(R))[2])
    if R.sym_deg[1]
        print(io, Indent(), "on symmetric forms of degree ", R.sym_deg[2])
        print(io, Dedent())
    else
        println(io, Indent(), "with representation matrix")
        show(io, R.rep_mat)
        print(io, Dedent())
    end
end

function direct_sum(X::RepresentationLinearlyReductiveGroup, Y::RepresentationLinearlyReductiveGroup)
    @req group(X) == group(Y) "not compatible"
    G = group(X)
    R = base_ring(group_ideal(G))
    Mat = block_diagonal_matrix(R, [Matrix(representation_matrix(X)), Matrix(representation_matrix(Y))])
    return RepresentationLinearlyReductiveGroup(G, Mat)
end

function direct_sum(V::Vector{RepresentationLinearlyReductiveGroup})
    n = length(V)
    G = group(V[1])
    for i in 2:n
        @req G == group(V[i]) "not compatible"
    end
    R = base_ring(group_ideal(G))
    Mat = block_diagonal_matrix(R, [Matrix(representation_matrix(V[i])) for i in 1:n])
    return RepresentationLinearlyReductiveGroup(G, Mat)
end

function tensor(X::RepresentationLinearlyReductiveGroup, Y::RepresentationLinearlyReductiveGroup)
    @req group(X) == group(Y) "not compatible"
    Mat = kronecker_product(representation_matrix(X), representation_matrix(Y))
    return RepresentationLinearlyReductiveGroup(group(X), Mat)
end

function tensor(V::Vector{RepresentationLinearlyReductiveGroup})
    n = length(V)
    for i in 2:n
        @req group(V[1]) == group(V[i]) "not compatible"
    end
    Mat = representation_matrix(V[1])
    for i in 2:n
        Mat = kronecker_product(Mat,representation_matrix(V[i]))
    end
    return RepresentationLinearlyReductiveGroup(group(V[1]), Mat)
end

###############

#computes the representation matrices of SL_m acting over m-forms of symmetric degree sym_deg
function rep_mat_(G::LinearlyReductiveGroup, sym_deg::Int)
    G.group[1] == :SL || error("Only implemented for SLm")
    m = G.group[2]
    R = base_ring(group_ideal(G))
    mixed_ring, t = polynomial_ring(R, "t" => 1:m)
    group_mat = natural_representation(G)
    new_vars = group_mat*t

    b = [ multinomial(sym_deg, first(AbstractAlgebra.exponent_vectors(a)))*a for a in monomials_of_degree(mixed_ring, sym_deg) ]
    n = length(b)

    # transform the b elements
    images_of_b = [evaluate(f, new_vars) for f in b]

    mat = zero_matrix(R, n, n)
    for j in 1:n
        f = images_of_b[j]
        x = mixed_ring()
        # express f as a linear combination of elements in b
        for i in 1:n
            c = coeff(f, leading_exponent(b[i]))
            mat[i,j] = c / leading_coefficient(b[i])
        end
    end
    return mat
end

#used to compute multinomial expansion coefficients
function multinomial(n::Int, v::AbstractVector{<:IntegerUnion})
    x = prod(factorial, v)
    return Int(factorial(n)/x)
end

##########################
#Invariant Rings of Reductive groups
##########################
@attributes mutable struct RedGroupInvarRing{FldT, PolyRingElemT, PolyRingT}
    field::FldT
    poly_ring::PolyRingT # graded

    group::LinearlyReductiveGroup
    representation::RepresentationLinearlyReductiveGroup

    reynolds_operator::Function

    fundamental::Vector{PolyRingElemT}
    presentation::MPolyAnyMap{MPolyQuoRing{PolyRingElemT}, PolyRingT, Nothing, PolyRingElemT}

    #Invariant ring of reductive group G (in representation R), no other input.
    function RedGroupInvarRing(R::RepresentationLinearlyReductiveGroup) #here G already contains information n and rep_mat
        G = group(R)
        K = field(G)
        n = ncols(R.rep_mat)
        poly_ring, _ = graded_polynomial_ring(K, "X" => 1:n)
        z = new{typeof(K), elem_type(poly_ring), typeof(poly_ring)}()
        z.representation = R
        z.group = G
        z.field = K
        z.poly_ring = poly_ring
        z.reynolds_operator = reynolds_v_slm
        return z
    end

    #to compute invariant ring ring^G where G is the reductive group of R. 
    function RedGroupInvarRing(R::RepresentationLinearlyReductiveGroup, ring::MPolyDecRing)
        n = ncols(R.rep_mat)
        n == ngens(ring) || error("The given polynomial ring is not compatible.")
        G = group(R)
        K = field(G)
        z = new{typeof(K), elem_type(ring), typeof(ring)}()
        if isdefined(R, :weights)
            #dosomething
        end
        z.representation = R
        z.group = G
        z.field = K
        z.poly_ring = ring
        z.reynolds_operator = reynolds_v_slm
        return z
    end
end

@doc raw"""
    invariant_ring(r::RepresentationLinearlyReductiveGroup)

Return the invariant ring under the action defined by the representation `r` on an implicitly generated polynomial ring of appropriate dimension.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 2, QQ);

julia> r = representation_on_forms(G, 2);

julia> RG = invariant_ring(r)
Invariant Ring of
graded multivariate polynomial ring in 3 variables over QQ
  under group action of SL2
```
"""
invariant_ring(R::RepresentationLinearlyReductiveGroup) = RedGroupInvarRing(R)

@doc raw"""
    invariant_ring(R::MPolyDecRing, r::RepresentationLinearlyReductiveGroup)

Return the invariant subring of `R` under the action induced by the representation of `r` on `R`.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 3, QQ);

julia> r = representation_on_forms(G, 3);

julia> S, x = graded_polynomial_ring(QQ, "x" => 1:10);

julia> RG = invariant_ring(S, r)
Invariant Ring of
graded multivariate polynomial ring in 10 variables over QQ
  under group action of SL3
```
"""
invariant_ring(ring::MPolyDecRing, R::RepresentationLinearlyReductiveGroup) = RedGroupInvarRing(R, ring)

@attr MPolyIdeal function null_cone_ideal(R::RedGroupInvarRing)
    Z = R.representation
    I, _ = proj_of_image_ideal(group(Z), Z.rep_mat)
    return ideal(generators(Z.group, I, Z.rep_mat))
end

polynomial_ring(R::RedGroupInvarRing) = R.poly_ring
group(R::RedGroupInvarRing) = R.group
representation(R::RedGroupInvarRing) = R.representation

@doc raw"""
    fundamental_invariants(RG::RedGroupInvarRing)

Return a system of fundamental invariants for `RG`.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 2, QQ);

julia> r = representation_on_forms(G, 2);

julia> RG = invariant_ring(r);

julia> fundamental_invariants(RG)
1-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 -X[1]*X[3] + X[2]^2

```
"""
function fundamental_invariants(z::RedGroupInvarRing) #unable to use abstract type
    if !isdefined(z, :fundamental)
        R = z.representation
        I, M = proj_of_image_ideal(R.group, R.rep_mat)
        null_cone_ideal(z) = ideal(generators(R.group, I, R.rep_mat))
        z.fundamental = inv_generators(null_cone_ideal(z), R.group, z.poly_ring, M, z.reynolds_operator)
    end
    return copy(z.fundamental)
end

function Base.show(io::IO, R::RedGroupInvarRing) 
    io = pretty(io)
    println(io, "Invariant Ring of")
    println(io, Lowercase(), R.poly_ring)
    print(io, Indent(),  "under group action of ", R.group.group[1], R.group.group[2])
    print(io, Dedent())
end

#computing the graph Gamma from Derksens paper
function image_ideal(G::LinearlyReductiveGroup, rep_mat::MatElem)
    R = base_ring(rep_mat)
    n = ncols(rep_mat)
    m = G.group[2]
    mixed_ring_xy, x, y, zz = polynomial_ring(G.field, "x"=>1:n, "y"=>1:n, "zz"=>1:m^2)
    ztozz = hom(R,mixed_ring_xy, gens(mixed_ring_xy)[(2*n)+1:(2*n)+(m^2)])
    genss = [ztozz(f) for f in gens(G.group_ideal)]
    #rep_mat in the new ring
    new_rep_mat = matrix(mixed_ring_xy,n,n,[ztozz(rep_mat[i,j]) for i in 1:n, j in 1:n])
    new_vars = new_rep_mat*x
    ideal_vect = y - new_vars 
    ideal_vect = vcat(ideal_vect,genss)
    return ideal(mixed_ring_xy, ideal_vect), new_rep_mat
end

#computing I_{\Bar{B}}
function proj_of_image_ideal(G::LinearlyReductiveGroup, rep_mat::MatElem)
    W = image_ideal(G, rep_mat)
    mixed_ring_xy = base_ring(W[2])
    n = ncols(rep_mat)
    m = G.group[2]
    #use parallelised groebner bases here. This is the bottleneck!
    return eliminate(W[1], gens(mixed_ring_xy)[(2*n)+1:(2*n)+(m^2)]), W[2]
end

#this function gets the generators of the null cone. they may or may not be invariant.
#to do this we evaluate what is returned from proj_of_image_ideal at y = 0 
#ie at gens(basering)[n+1:2*n] = [0 for i in 1:n]
function generators(G::LinearlyReductiveGroup, X::MPolyIdeal, rep_mat::MatElem)
    n = ncols(rep_mat)
    m = G.group[2]
    gbasis = gens(X) 
    length(gbasis) == 0 && return gbasis
    mixed_ring_xy = parent(gbasis[1])
    #evaluate at gens(mixed_ring_xy)[n+1:2*n] = 0
    V = vcat(gens(mixed_ring_xy)[1:n], [0 for i in 1:n], gens(mixed_ring_xy)[2*n+1:2*n+m^2])
    ev_gbasis = [evaluate(f,V)  for f in gbasis]
    #grading starts here. In the end, our invariant ring is graded.
    mixed_ring_graded, _ = grade(mixed_ring_xy)
    mapp = hom(mixed_ring_xy, mixed_ring_graded, gens(mixed_ring_graded))
    ev_gbasis_new = [mapp(ev_gbasis[i]) for i in 1:length(ev_gbasis)]
    if length(ev_gbasis_new) == 0
        return [mixed_ring_graded()]
    end
    return minimal_generating_set(ideal(ev_gbasis_new))
end

#computing the invariant generators of the null cone by applying reynolds operator to gens(I). This is done in K[X,Y] (basering(I)).
#the elements returned will be in the polynomial K[X] (ringg).
function inv_generators(I::MPolyIdeal, G::LinearlyReductiveGroup, ringg::MPolyRing, M::MatElem, reynolds_function::Function)
    genss = gens(I)
    if length(genss) == 0
        return Vector{elem_type(ringg)}()
    end

    #we need the representation matrix and determinant of group matrix to be in basering(I)
    mixed_ring_xy = parent(genss[1])
    R = base_ring(M)
    m = G.group[2]
    n = ncols(M)
    mapp = hom(R, mixed_ring_xy, gens(mixed_ring_xy))
    new_rep_mat = matrix(mixed_ring_xy,n,n,[mapp(M[i,j]) for i in 1:n, j in 1:n])
    det_ = det(G.canonical_representation)
    mapp_ = hom(parent(det_), mixed_ring_xy, gens(mixed_ring_xy)[(2*n)+1:(2*n)+(m^2)])
    new_det = mapp_(det_)

    #now we apply reynolds operator to genss
    if G.group[1] == :SL #TODO other types of reductive groups
        new_gens_wrong_ring = [reynolds_function(genss[i], new_rep_mat, new_det, m) for i in 1:length(genss)]
    else 
        return nothing
    end

    #map them to the required ring, ringg. 
    img_genss = vcat(gens(ringg), zeros(ringg, n+m^2))
    mixed_to_ring = hom(mixed_ring_xy, ringg, img_genss)
    new_gens = Vector{elem_type(ringg)}()
    for elemm in new_gens_wrong_ring
        if elemm != 0
            push!(new_gens, mixed_to_ring(elemm))
        end
    end
    if length(new_gens) == 0
        return [ringg()]
    end
    
    #remove ugly coefficients: 
    V= Vector{FieldElem}[]
    new_gens_ = Vector{elem_type(ringg)}()
    for elem in new_gens
        V = vcat(V,collect(coefficients(elem)))
        maxx = maximum([abs(denominator(V[i])) for i in 1:length(V)])
        minn = minimum([abs(numerator(V[i])) for i in 1:length(V)])
        if denominator((maxx*elem)//minn) != 1
            error("den not 1")
        end
        push!(new_gens_, numerator((maxx*elem)//minn))
        V= Vector{FieldElem}[]
    end
    return new_gens_
end

#the reynolds operator for SLm acting via new_rep_mat. 
function reynolds_v_slm(elem::MPolyDecRingElem, new_rep_mat::MatElem, new_det::MPolyDecRingElem, m::Int)
    mixed_ring_xy = parent(elem)
    n = ncols(new_rep_mat)
    new_vars = new_rep_mat*gens(mixed_ring_xy)[1:n]
    sum_ = mixed_ring_xy()
    phi = hom(mixed_ring_xy, mixed_ring_xy, vcat(new_vars, [0 for i in 1:ncols(new_rep_mat)+m^2]))
    sum_ = phi(elem)
    t = needed_degree(sum_, m)
    if !is_divisible_by(t, m)
        return parent(elem)()
    else
        p = divexact(t, m)
    end
    #num = omegap_(p, new_det, sum_)
    #den = omegap_(p, new_det, (new_det)^p)
    #if !(denominator(num//den)==1)
    #    error("denominator of reynolds not rational")
    #end
    #return numerator(num//den)
    return reynolds_slm(sum_, new_det, p)
end

#reynolds operator for SLm using Cayleys Omega process 
function reynolds_slm(elem::MPolyRingElem, det_::MPolyRingElem, p::Int)
    num = omegap_(p,det_, elem)
    den = omegap_(p,det_,det_^p)
    if !(denominator(num//den)==1)
        error("denominator of reynolds not rational")
    end
    return numerator(num//den)
end

#used to compute the degree p of omega_p
#computes the degree of the z_ij variables of the leading term of elem.
function needed_degree(elem_::MPolyDecRingElem, m::Int)
    elem = leading_monomial(elem_)
    R = parent(elem)
    n = ngens(R) - m^2
    extra_ring, _= polynomial_ring(base_ring(R), "z"=>1:m^2)
    mapp = hom(R,extra_ring, vcat([1 for i in 1:n], gens(extra_ring)))
    return total_degree(mapp(elem))
end

function omegap_(p::Int, det_::MPolyDecRingElem, f::MPolyDecRingElem)
    parent(det_) == parent(f) || error("Omega process ring error")
    action_ring = parent(det_)
    monos = collect(monomials(det_))
    coeffs = collect(coefficients(det_))
    for i in 1:p
        h = action_ring()
        for i in 1:length(monos)
            exp_vect = exponent_vector(monos[i], 1)
            x = f
            for i in 1:length(exp_vect), j in 1:exp_vect[i]
                x = derivative(x, i)
                iszero(x) && break
            end
            h += coeffs[i]*x
        end
        f = h
    end
    return f
end

#####################callable reynold's operator

#this function returns the image of elem under the reynolds operator of group with representation X
function reynolds_operator(X::RepresentationLinearlyReductiveGroup, elem::MPolyRingElem)
    X.group.group[1] == :SL || error("Only implemented for SLm")
    vector_ring = parent(elem)
    G = X.group
    n = ngens(vector_ring)
    n == ncols(X.rep_mat) || error("group not compatible with element")
    m = G.group[2]
    R, _ = graded_polynomial_ring(G.field,"x"=>1:n, "y"=>1:n, "z"=>(1:m, 1:m))
    map1 = hom(vector_ring, R, gens(R)[1:n])
    new_elem = map1(elem)
    group_ring = base_ring(X.rep_mat)
    map2 = hom(group_ring, R, gens(R)[2*n+1:2*n+m^2])
    new_rep_mat = map_entries(map2, X.rep_mat)
    new_det = map2(det(G.canonical_representation))
    f = X.reynolds_v(new_elem, new_rep_mat, new_det, m)
    reverse_map = hom(R, vector_ring, vcat(gens(vector_ring), [0 for i in 1:n+m^2]))
    return reverse_map(f)
end

@doc raw"""
    reynolds_operator(RG::RedGroupInvarRing, f::MPolyRingElem)

Return the image of `f` under the Reynolds operator corresponding to `RG`.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 3, QQ);

julia> r = representation_on_forms(G, 3);

julia> S, x = graded_polynomial_ring(QQ, "x" => 1:10);

julia> RG = invariant_ring(S, r);

julia> 75*reynolds_operator(RG, x[5]^4)
x[1]*x[4]*x[8]*x[10] - x[1]*x[4]*x[9]^2 - x[1]*x[5]*x[7]*x[10] + x[1]*x[5]*x[8]*x[9] + x[1]*x[6]*x[7]*x[9] - x[1]*x[6]*x[8]^2 - x[2]^2*x[8]*x[10] + x[2]^2*x[9]^2 + x[2]*x[3]*x[7]*x[10] - x[2]*x[3]*x[8]*x[9] + x[2]*x[4]*x[5]*x[10] - x[2]*x[4]*x[6]*x[9] - 2*x[2]*x[5]^2*x[9] + 3*x[2]*x[5]*x[6]*x[8] - x[2]*x[6]^2*x[7] - x[3]^2*x[7]*x[9] + x[3]^2*x[8]^2 - x[3]*x[4]^2*x[10] + 3*x[3]*x[4]*x[5]*x[9] - x[3]*x[4]*x[6]*x[8] - 2*x[3]*x[5]^2*x[8] + x[3]*x[5]*x[6]*x[7] + x[4]^2*x[6]^2 - 2*x[4]*x[5]^2*x[6] + x[5]^4
```
"""
function reynolds_operator(R::RedGroupInvarRing, elem::MPolyRingElem)
    X = R.representation
    return reynolds_operator(X, elem)
end

include("TorusInvariantsFast.jl")


#####################Invariant rings as affine algebras

@doc raw"""
    affine_algebra(RG::RedGroupInvarRing)

Return the invariant ring `RG` as an affine algebra (this amounts to compute the algebra syzygies among the fundamental invariants of `RG`).

In addition, if `A` is this algebra, and `R` is the polynomial ring of which `RG` is a subalgebra,
return the inclusion homomorphism  `A` $\hookrightarrow$ `R` whose image is `RG`.

# Examples
```jldoctest
julia> G = linearly_reductive_group(:SL, 2, QQ);

julia> r = representation_on_forms(G, 2);

julia> S, x = graded_polynomial_ring(QQ, "x" => 1:3);

julia> RG = invariant_ring(S, r);

julia> A, AtoS = affine_algebra(RG)
(Quotient of multivariate polynomial ring by ideal (0), Hom: A -> S)
```
"""
function affine_algebra(R::RedGroupInvarRing)
  if !isdefined(R, :presentation)
    V = fundamental_invariants(R)
    s = length(V)
    weights_ = zeros(Int, s)
    for i in 1:s
        weights_[i] = total_degree(V[i])
    end
    S,_ = graded_polynomial_ring(field(group(representation(R))), "t"=>1:s; weights = weights_)
    R_ = polynomial_ring(R)
    StoR = hom(S,R_,V)
    I = kernel(StoR)
    Q, StoQ = quo(S,I)
    QtoR = hom(Q,R_,V)
    R.presentation = QtoR
  end
  return domain(R.presentation), R.presentation
end