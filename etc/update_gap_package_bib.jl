# Synchronize the bibliography entries for GAP packages in
# docs/oscar_references.bib with the package versions shipped by the GAP.jl
# version in the current environment.
#
# Run from the root directory of the Oscar.jl repository with:
# > julia --project=. etc/update_gap_package_bib.jl
#
# Pass `--check` to only report outdated entries (exit code 1) without
# modifying any files.
#
# Entries are recognized by the field `note = {GAP package}`; the package name
# is taken from the start of the `title` field. The author, title, year, month
# and url fields are regenerated from the `PackageInfo.g` record of the
# installed package. If the citation key changes (it encodes the authors and
# the year), all `@cite` references in `docs/` and in docstrings are updated.
#
# note: the @main function requires julia 1.11 or newer

using GAP

const oscardir = normpath(@__DIR__, "..")
const bibfile = joinpath(oscardir, "docs", "oscar_references.bib")

const entry_regex = r"^@Misc\{(?<key>[^,\s]+),\n(?<body>(?:  .*\n)*?)\}\n"m
const field_regex = r"^  (?<name>\w+)\s*=\s*\{?(?<value>.*?)\}?,?$"m

const months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

function parse_fields(body::AbstractString)
  return Dict{String,String}(m[:name] => m[:value] for m in eachmatch(field_regex, body))
end

function package_name(fields::Dict{String,String})
  haskey(fields, "title") || return nothing
  m = match(r"^([^,\s]+),", fields["title"])
  return isnothing(m) ? nothing : m[1]
end

function package_info(name::AbstractString)
  infos = GAP.Globals.GAPInfo.PackagesInfo
  sym = Symbol(lowercase(name))
  hasproperty(infos, sym) || error("GAP package `$name` is not available in the current GAP installation")
  # the first entry is the one with the highest version
  return getproperty(infos, sym)[1]
end

# accepts dd/mm/yyyy and yyyy-mm-dd, the two date formats allowed in PackageInfo.g
function parse_date(date::AbstractString)
  m = match(r"^(\d{2})/(\d{2})/(\d{4})$", date)
  !isnothing(m) && return parse(Int, m[3]), parse(Int, m[2])
  m = match(r"^(\d{4})-(\d{2})-(\d{2})$", date)
  !isnothing(m) && return parse(Int, m[1]), parse(Int, m[2])
  error("cannot parse date `$date`")
end

# mimics the key.format rule of .bibtoolrsc:
# three letters of the last name for a single author, otherwise the initials
# of all authors (one letter per word of the last name, joined by `-`)
function bib_key(lastnames::Vector{String}, year::Int)
  yy = lpad(year % 100, 2, '0')
  if length(lastnames) == 1
    return first(only(lastnames), 3) * yy
  end
  initials = map(lastnames) do name
    join((uppercase(first(word)) for word in split(name)), "-")
  end
  return join(initials) * yy
end

function generate_entry(name::AbstractString)
  info = package_info(name)
  persons = [p for p in info.Persons if hasproperty(p, :IsAuthor) && p.IsAuthor]
  isempty(persons) && error("GAP package `$name` has no authors in its `PackageInfo.g`")
  lastnames = [String(p.LastName) for p in persons]
  authors = join(("$(String(p.LastName)), $(String(p.FirstNames))" for p in persons), " and ")
  year, month = parse_date(String(info.Date))
  key = bib_key(lastnames, year)
  title = "$(String(info.PackageName)), $(String(info.Subtitle)), Version $(String(info.Version))"
  url = String(info.PackageWWWHome)
  text = """
    @Misc{$key,
      author        = {$authors},
      title         = {$title},
      note          = {GAP package},
      year          = {$year},
      month         = $(months[month]),
      url           = {$url}
    }
    """
  return key, text
end

# rewrite `[OLD](@cite)`-style references (including variants like
# `[OLD; text](@cite)` and `[OLD, KEY2](@citet)`) to the new key;
# returns the paths of the modified files
function update_citations(old::AbstractString, new::AbstractString; check::Bool)
  cite_regex = r"\[[^\[\]]*\]\(@cite[^)]*\)"
  key_regex = Regex("(?<![\\w-])" * old * "(?![\\w-])")
  modified = String[]
  for dir in ["docs/src", "src", "experimental"], (root, _, files) in walkdir(joinpath(oscardir, dir))
    for file in files
      endswith(file, ".md") || endswith(file, ".jl") || continue
      path = joinpath(root, file)
      content = read(path, String)
      occursin(old, content) || continue
      updated = replace(content, cite_regex => s -> replace(s, key_regex => new))
      updated == content && continue
      push!(modified, relpath(path, oscardir))
      check || write(path, updated)
    end
  end
  return modified
end

function (@main)(args)
  check = "--check" in args
  bib = read(bibfile, String)
  updated = bib
  outdated = 0
  for m in eachmatch(entry_regex, bib)
    fields = parse_fields(m[:body])
    get(fields, "note", "") == "GAP package" || continue
    name = package_name(fields)
    isnothing(name) && error("cannot determine package name of bib entry `$(m[:key])`")
    key, text = generate_entry(name)
    text == m.match && continue
    outdated += 1
    println("$name: entry `$(m[:key])` is outdated")
    updated = replace(updated, m.match => text)
    new_fields = parse_fields(text)
    for field in ["author", "title", "year", "month", "url"]
      old_value, new_value = get(fields, field, ""), get(new_fields, field, "")
      old_value == new_value && continue
      if length(old_value) + length(new_value) < 80
        println("  $field: $old_value -> $new_value")
      else
        println("  $field: $old_value")
        println("  $(" "^length(field))  -> $new_value")
      end
    end
    key == m[:key] && continue
    other = match(Regex("^@\\w+\\{" * key * ",", "m"), bib)
    isnothing(other) || error("new key `$key` for `$name` collides with an existing entry")
    println("  key: $(m[:key]) -> $key")
    for path in update_citations(m[:key], key; check)
      println("    citations in $path")
    end
  end
  if outdated == 0
    println("All GAP package entries in docs/oscar_references.bib are up to date.")
    return 0
  end
  if check
    println("\n$outdated outdated entries. Run without `--check` to update them.")
    return 1
  end
  write(bibfile, updated)
  println("\nUpdated $outdated entries. Now run bibtool to standardize the bibliography:")
  println("  bibtool -r .bibtoolrsc docs/oscar_references.bib -o docs/oscar_references.bib")
  return 0
end
