---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Building a Schema Registry from Scratch for a Scientific Data Platform"
subtitle: ""
summary: ""
authors: []
tags: [Pandera, YAML, AWS]
categories: [data platform, software engineering]
date:   2025-06-24T09:00:00-07:00
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

When I joined Just-Evotec Biologics (first as a data scientist, now as a data platform engineer), I inherited a data ecosystem that probably looked pretty familiar to what lots of others have dealth with: a dozen scientific instruments each outputting data in proprietary formats, a LIMS system with its own schema, upstream and downstream experimental systems, Excel workbooks scientists had been maintaining for years but hidden away from any production storage system, and a swathe of applications that had been developed previously but had very little in the way of data governance. We didn't have a central schema definitions, very little in the way of contracts between producers (e.g. instrumentation) and consumers (e.g. scientists, applications, clients, more instruments), and no way to ask or answer "what's being pulled down here?".

I've been slowly building up our data platform, including implementing a formal schema registry.  Here, I'll cover some core design decisions I made and patterns that worked for me for the registry. The implementation is domain (and in our case, functional group and stakeholder) agnostic.

---

## Why not just use an existing registry tool?

Some alternative solutions to implementing / using a schema registry include Confluent's Schema Registry, AWS Glue, Great Expectations, etc.  Confluent's Schema Registry is excellent for Kafka-based event streams, AWS Glue has a data catalog, and Great Expectations handles data quality well (just like Pandera).  But none of those really addressed all or most of my needs, or fit in with my environment: a mix of validated DataFrames, LIMS API outputs, Parquet files in S3, and a team of scientists, some of whom wrote Python but weren't data engineers. I wanted the following:

1. Define schemas as Python classes with static type annotations
2. Automatically serialize those classes to human-readable YAML
3. Query schemas by metadata (tier, data lineage stage, source system)
4. Reconstruct a live Pandera model from a stored YAML definition at runtime

We're primarily working with data tables (as opposed to events), so I wanted a coupling between a type agnostic representation like YAML and Pandera.  However, I've since extended a lot of this functionality for event-based schemas.  At some point, I might want to revisit Glue again so I don't reinvent the wheel.

---

## Core architecture

The general schema development flow is: **write Python → export YAML → publish to S3 → consume via the registry client at runtime**.

```
author a Pandera contract  (contracts/domains/**/schema.py)
   → export-models-to-yaml       # Python model to canonical YAML
   → upload-yaml-to-s3           # publish, through the canonical-dtype gate
        S3  (what consumers actually read)
   → REGISTRY.get_pandera_model(name)    # at runtime, in a pipeline
        → a live Pandera DataFrameModel
```

The important property of this diagram is the direction of the arrow into S3. Python is how schemas are *authored*, but S3 is what consumers *read*. A pipeline never imports a contract class. It fetches YAML and builds a Pandera model from it at runtime, which means a schema change propagates by re-publishing to S3, with no rebuild or redeploy of any consumer.  I initially didn't build this in, and found myself needed to re-install the registry every time I authored a new contract.  Not ideal.  

The repository is a monorepo of three independently versioned pieces:

| Piece | What it is | Who uses it |
|---|---|---|
| the service | Contract definitions, templates, source-system specs, the FastAPI API, and the export/publish tooling | Deployed as a Lambda. Not installed as a library. |
| the client | Fetch schemas from S3 and deserialize them to Pandera models, plus the canonical dtype vocabulary | Pipelines, and anything validating data against a schema (e.g. dashboards) |
| the data IO package | Connectors for the LIMS and for the parquet/delta lakehouse | Pipelines |

I started with one package and split it once pipelines started depending on it. A pipeline that just wants to validate a DataFrame should not be installing FastAPI, `jsonschema`, and the whole publish toolchain to do it. The client should be thin, and the dependency direction one-directional a.k.a. the service depends on the client.

### Repository layout

The code tree looks like this. Names are genericized so as to hide our proprietary namespaces and functionality, but the shape is exactly what we run:

```
schema-registry/
├── registry/                          # the service
│   ├── contracts/
│   │   ├── templates/                 # JSON Schema per schema_type
│   │   │   ├── dataframe/v1_0/schema.yaml
│   │   │   ├── event/v1_0/schema.yaml
│   │   │   └── api/v1_0/schema.yaml
│   │   ├── domains/                   # the contracts themselves
│   │   │   ├── lab/
│   │   │   │   └── analytics/
│   │   │   │       └── cell_count/
│   │   │   │           ├── v1_0/
│   │   │   │           │   ├── schema.py      # authored
│   │   │   │           │   └── schema.yaml    # generated, committed
│   │   │   │           └── v2_0/
│   │   │   │               ├── schema.py
│   │   │   │               └── schema.yaml
│   │   │   ├── operations/
│   │   │   └── enterprise/
│   │   └── utilities/dataframe/export.py      # Python model → YAML
│   ├── integrations/
│   │   └── source_specs/              # contract → physical source table
│   │       └── lab/analytics/cell_count/v1_0/spec.yaml
│   ├── api/                           # FastAPI app (deployed as a Lambda)
│   │   ├── app.py
│   │   ├── auth.py
│   │   └── routers/{domains,schemas,specs}.py
│   ├── publish/sync_schemas.py        # validation gates + S3 upload
│   └── scripts/                       # the two CLI entry points
│
└── packages/
    ├── schema-registry-client/        # what pipelines + dashboards install
    │   └── schema_registry_client/
    │       ├── contracts/utilities/dataframe/
    │       │   ├── dtypes.py          # the canonical vocabulary
    │       │   ├── mixins.py          # SchemaInfo, SchemaMeta, ContractMixin (e.g. constants + fields applied to all schemas)
    │       │   ├── registration.py    # the decorator + path checks
    │       │   └── base.py            # base DataFrameModel configs
    │       └── io/
    │           ├── registry.py        # the consumer-facing Registry
    │           ├── backends/s3.py     # index-backed S3 reads
    │           └── adapters/          # YAML → live Pandera model
    └── data-io/                       # source-system and lakehouse connectors
```

I wanted to be able to seperate the client from the registry and contracts, so I want to emphasize which side of the `packages/` line each concern lives on. Everything a *consumer* needs, the dtype vocabulary, the identity dataclasses, the deserializer, sits in the client. Everything about *producing* the registry, discovery, export, validation gates, upload, and the API, sits in the service. The decorator lives in the client rather than the service, which looks odd at first, but contracts are authored against it and the deserializer needs the same `SchemaInfo` shape when it rebuilds a model, so it belongs on the shared side.

The generated `schema.yaml` sitting next to the authored `schema.py` and getting committed is intentional. A schema change shows up in code review as a readable diff against the previous commit of the actual YAML contract, not just as a Python class that someone would have to mentally compile.

### Adding a schema, end to end

The whole process for a contributor is only five steps:

1. Create `contracts/domains/<domain>/<subdomains>/<entity>/v1_0/schema.py` and write the Pandera model, decorated with `@register_dataframe_schema`.
2. If it maps to a physical source table, add the matching spec under `integrations/source_specs/`.
3. Run the export command. It walks the tree, checks that the declared name and version match the directory path, and writes `schema.yaml` next to each `schema.py`.
4. Commit both files. CI re-runs the export and fails the build if anything is out of date.
5. Run the upload command. It validates every document against its template, runs the canonical dtype gate, uploads to S3, and rewrites the index.

```bash
poetry run export-models-to-yaml      # Python models → canonical schema.yaml
poetry run upload-yaml-to-s3          # validate, publish, reindex
```

Consumers of the registry pick the changes up on their next run, without any intermediate rebuilds or redeploys. So the rest of my post is mostly about what happens inside steps 3 and 5.

---

## Schema identity: the domain/subdomain/entity pattern

I was very opinionated and rigid about the *structure* of the registry, and not just about how to define the contracts themselves.  Every schema gets a unique dotted name composed of domain, zero or more subdomains, and an entity name:

```
 * lab.analytics.cell_count
 * lab.upstream.bioreactor_run
 * operations.equipment.instrument
 * enterprise.finance.purchase_order
```

This naming scheme is enforced structurally. Schemas live at file paths that mirror their names:

```
registry/contracts/domains/lab/analytics/cell_count/v1_0/schema.py
```

The `@register_dataframe_schema` decorator captures the identity at class definition time:

```python
@register_dataframe_schema(
    domain="lab",
    subdomains=["analytics"],
    entity="cell_count",
    version="1.0",
    description="LIMS cell count assay table.",
    meta=SchemaMeta(
        tier="bronze",
        alignment="source",
        source_system="lims"
    )
)
class LIMSCellCountSchema(ContractMixin, LIMSBaseSchema):
    run_row_id: str = pa.Field(coerce=True)
    sample_id: str = pa.Field()
    vcd: Optional[float] = pa.Field(nullable=True, coerce=True)
    viability: Optional[float] = pa.Field(nullable=True, coerce=True)
    run_date: Timestamp = pa.Field(nullable=True, coerce=True)
```

The decorator is thin and only builds a frozen `SchemaInfo`, derives the dotted name from its parts, and stamps both onto the class:

```python
def _register(cls):
    info = SchemaInfo(
        domain=domain,
        subdomains=subdomains,
        entity=entity,
        version=version,
        owner=owner,
        description=description,
    )
    cls.__schema_info__ = info
    cls.__schema_meta__ = meta or SchemaMeta()
    return cls
```

`SchemaInfo.__post_init__` does a quick n' dirty validation by rejecting any domain, subdomain, or entity containing `.`, `/`, or `-`, since those would corrupt the dotted name or the path it maps to, and then joins the parts into `name`.  The more expensive checks, that the folder version matches the declared version (`v1_0` → `1.0`) and that the directory path matches the dotted name, run at **export time**, not at import time:

```python
if RegistryConfig.enforce_domain_name:
    confirm_schema_name_matches_module(cls=cls, name=info.name)

if RegistryConfig.enforce_path_version:
    confirm_schema_version_matches_module_version(cls=cls, version=info.version)
```

Enforcing contract path structure at import time makes the contract classes impossible to define anywhere else, which is a problem the first time a scientist wants to draft a schema in a notebook to see what it looks like. Doing it at export means the rule is enforced on everything that gets published, while drafting stays cheap. There's a context manager for the notebook usecase too:

```python
with relaxed_registry_checks():
    @register_dataframe_schema(...)
    class DraftSchema(ContractMixin, BaseDataFrameSchema):
        ...
```

But there is a tradeoff, such a badly-placed schema fails later than it could. In practice "later" is the export step, which runs in CI on every PR, so nothing badly-placed reaches S3 regardless.  Contracts inherit from a base model that sets the validation posture in one place:

```python
class BaseDataFrameSchema(pa.DataFrameModel):
    class Config:
        strict = 'filter'
        coerce = True
```

`strict='filter'` drops columns not in the schema rather than raising, which for source-system data is almost always what you want. The LIMS base adds `drop_invalid_rows = True` and the row identity columns every LIMS table carries.

---

## Versioning: semantic, path-encoded, and strict

Schema versions follow semantic versioning (`1.0`, `2.1`, `1.0.1`) and are encoded into the directory structure as Python-safe package names:

```
v1_0   →   1.0
v2_1   →   2.1
v1_0_1 →   1.0.1
```

The conversion is bidirectional and validated in both directions. When I need to add a new version of a schema, I create a new directory alongside the old one. Both continue to exist and be served by the registry.

```
cell_count/
  v1_0/
    schema.py
    schema.yaml     ← auto-generated
  v2_0/             ← new version; v1_0 still works
    schema.py
    schema.yaml
```

Version resolution supports three modes: a specific version (`"1.0"`), `"latest"` (resolved by semantic comparison at read time), and `None` (all versions). This last mode is useful when you need to understand the full version history of a schema.  Resolving `latest` uses `packaging.version.Version` for comparison rather than string sorting, so `10.0` sorts above `9.0`.

```python
for strver in vers:
    semver = Version(strver)
    # don't allow pre-releases, or dev-releases
    if semver.pre or semver.dev:
        continue
    parsed.append((semver, strver))
```

So I can publish `2.0.0rc1`, point a pipeline at it explicitly to test, and know that nothing pinned to `latest` will pick it up by accident.

---

## Export pipeline: python → YAML

Rather than maintaining YAML files by hand, the build step automatically discovers and converts decorated Pandera models.  Discovery works by walking the file tree looking for `schema.py` files, dynamically importing them as namespace packages (which avoid collisions between modules at the same relative path), and inspecting each imported module for classes that subclass both `pa.DataFrameModel` and `ContractMixin` and have a populated `__schema_info__`.  The code builds a unique dotted module name from the full path:

```python
def _path_to_module_name(filepath: Path, package_root: Path) -> str:
    rel = filepath.resolve().relative_to(package_root.resolve())
    parts = rel.with_suffix("").parts
    return '.'.join(parts)
    # → "contracts.domains.lab.analytics.cell_count.v1_0.schema"
```

Each import gets a unique name in `sys.modules` to prevent collisions (ideally we wouldn't be naming schemas the same name, but this approach allows for it).  Setting `mod.__package__` to the parent of that dotted name keeps relative imports inside the schema file working.

Pandera fields are serialized into a YAML-friendly dictionary, and checks that can be represented cleanly (e.g. comparisons and membership tests) are serialized.  Anything else is skipped with a warning, since they're harder to represent.  Not ideal if you *do* want some more complicated validation logic, but works for now -- though I think Great Expectations is probably better for these sorts of checks than Pandera is.

```python
# pa.Check.greater_than(0)      → {"gt": 0}
# pa.Check.isin(["A", "B"])     → {"isin": ["A", "B"]}
# lambda df: df["x"] > df["y"]  → warning, skipped
```

The serializer returns a *list* per check rather than a single dict, because some Pandera checks are compound. `in_range` has to expand into a `ge` entry and an `le` entry, since the YAML vocabulary has no range primitive.  The resulting YAML is human-readable and versionable:

```yaml
schema:
  name: lab.analytics.cell_count
  domain: lab
  entity: cell_count
  version: "1.0"
  owner: data-platform
  schema_type: dataframe
  description: LIMS cell count assay table.

meta:
  tier: bronze
  alignment: source
  source_system: LIMS

columns:
  - name: run_row_id
    dtype: str
    nullable: false
    coerce: true
  - name: viability
    dtype: float64
    nullable: true
    coerce: true
    checks:
      - ge: 0.0
      - le: 1.0
```

---

## Canonical dtype vocabulary

My initial version of a Python-to-YAML-to-Python round trip wrote out whatever dtype spelling the contract author (a.k.a. me) used. Pandera and pandas and `typing` will happily provide `float`, `float64`, `double`, `np.float64`, `typing.List[float]`, and `Timestamp` for what are actually three types. I didn't want consuming services to have to deal with this ambiguity.  The registry now defines a closed dtype vocabulary:

```
scalars:  str, int32, int64, float32, float64, bool, datetime64[ns]
lists:    List[<scalar>]   (element one of int/float/str/bool)
```

Author-side spellings are normalized to that vocabulary in exactly one function, `canonicalize_dtype`, called at export time:

```python
_SCALAR_ALIASES: Dict[str, str] = {
    "int": "int64",     "integer": "int64",
    "float": "float64", "double": "float64",
    "str": "str",       "string": "str",
    "bool": "bool",     "boolean": "bool",
    "datetime": "datetime64[ns]",
    "timestamp": "datetime64[ns]",
    "date": "datetime64[ns]",
    # ... plus the canonical spellings mapping to themselves
}
```

---

## Publishing contracts

The dtype vocabulary is only a contract if something enforces it, so publishing to S3 runs every document through a hard gate first:

```python
def assert_canonical_dtypes(doc, source="<doc>") -> None:
    schema = (doc or {}).get("schema", {})
    if schema.get("schema_type") != "dataframe":
        return

    problems = []
    for col in (doc.get("columns") or []):
        dtype = col.get("dtype")
        if dtype is None:
            continue
        try:
            canonical = canonicalize_dtype(dtype)
        except UnknownDtypeError as e:
            problems.append(f"column {col.get('name')!r}: {e}")
            continue
        if not is_canonical(dtype):
            problems.append(
                f"column {col.get('name')!r}: dtype {dtype!r} is not canonical "
                f"(expected {canonical!r}), re-export this schema."
            )

    if problems:
        raise ValueError(f"Refusing to publish {schema.get('name')!r}:\n  - " + "\n  - ".join(problems))
```

The two rejection cases are doing different jobs. Rejecting an unknown dtype catches a type consumers can't deserialize. Rejecting a dtype that is merely *non-canonical* (one that `canonicalize_dtype` could fix) catches something else entirely: it means this YAML was not produced by the current exporter. Someone hand-edited it, or it was generated before the normalization step existed. Silently canonicalizing it at publish time would hide that. Refusing forces a re-export, which keeps the YAML in S3 in sync with the Python that claims to define it.  The check acts as sort of a staleness detector.

---

## Schema templates: validating the schemas themselves

Separately from dtypes, each schema document is validated against a JSON Schema template selected by its `schema_type`:

```
contracts/templates/
  dataframe/v1_0/schema.yaml
  event/v1_0/schema.yaml
  api/v1_0/schema.yaml
```

At publish time the templates are themselves checked as valid JSON Schemas with `Draft202012Validator.check_schema`, compiled once, and then each contract is validated against the template matching its declared type. A schema with no `schema_type`, or one naming a type with no template, is a hard failure, and wont upload.

This is the layer that lets the registry hold more than DataFrames. `dataframe` contracts carry `columns`. `api` contracts carry `request`, `response`, and `callback` sections. `event` contracts carry their own shape. They all live in the same tree, share the same identity and versioning rules, and are all published through the same gate, but each is structurally validated against its own template.

---

## Schema metadata: queryable semantic tags

Every schema can carry structured metadata in a `SchemaMeta` dataclass:

```python
@dataclass(frozen=True)
class SchemaMeta:
    tier: Optional[Literal["bronze", "silver", "gold"]] = None
    alignment: Optional[Literal["source", "canonical", "denormalized"]] = None
    contract_type: Optional[Literal["ingress", "internal", "egress"]] = None
    source_system: Optional[Union[str, List[str]]] = None
    stage: Optional[str] = None
```

These fields encode the data's position in a medallion-style architecture. Bronze/silver/gold indicate the refinement level. Alignment captures whether data is still in the shape of its source system, has been canonicalized, or has been denormalized for consumption. Contract type captures directionality in the platform: ingress for uploads and instrument files, internal for the middle of pipelines, egress for published dashboards and APIs.  This metadata is queryable:

```python
registry = Registry(s3_bucket="my-data-lakehouse")

# Find all bronze schemas sourced from the LIMS
lims_bronze = registry.find_by_meta(tier="bronze", source_system="lims")

# Find all schemas used as egress contracts
egress_schemas = registry.find_by_meta(contract_type="egress")

# Get all tiers currently in use
registry.get_tiers()  # → ["bronze", "gold", "silver"]
```

This became invaluable for impact analysis. When a source system changed its output, I could immediately identify which schemas were `alignment="source"` and `source_system="lims"` and therefore potentially affected.

The same identity travels with the data, not just the registry. `ContractMixin` can flatten a contract into a string key/value header for stamping onto parquet metadata:

```python
{
  "contract.domain": "lab",
  "contract.entity": "cell_count",
  "contract.version": "1.0",
  ...
}
```

So a file on disk can answer which contract and which version produced it, without anyone having to consult a pipeline log.

---

## Runtime registry

The `Registry` class wraps an S3 backend and provides the consumer-facing API. It's thin by design. Most logic lives in the export pipeline and the contract definitions themselves.

```python
from schema_registry_client import REGISTRY

# Load a schema as a live Pandera model
Model = REGISTRY.get_pandera_model("lab.analytics.cell_count", version="latest")

# Validate a DataFrame against it
validated = Model.validate(df)

# Or get the raw YAML doc
doc = REGISTRY.get_schema("lab.analytics.cell_count", version="1.0")
```

`get_pandera_model` builds a class dynamically: each YAML column becomes a Pandera `Field` plus a type annotation, the check dicts become `Field` kwargs, and the schema's config overrides are applied on top of the base model's config. Because the dtype strings are guaranteed canonical, the annotation lookup is a single flat dict with seven entries and no fallbacks.

The backend reads an index CSV written at upload time rather than doing live `list_objects` calls:

```
contracts/index/schema_index.csv    # name, key, version, date, schema_type
integrations/index/spec_index.csv
```

Listing names, resolving versions, and enumerating domains are all filters over that dataframe. It loads once and stays cached on the backend instance. This keeps latency predictable and avoids a per-request S3 API call every time something enumerates the registry. The cost is that the index is a build artifact like everything else: it's rewritten on every publish, so it's accurate as of the last upload and no fresher.

Alongside the contracts, the registry stores integration specs that map a contract to its physical source table: schema and table name, a `field_to_source` column mapping, and the created/modified columns used for date partitioning. That's what lets a pipeline say "load this contract for this date" without knowing anything about the source system's table layout. It's also the seam where a source system renaming a column becomes a spec change rather than a pipeline change.

---

## API

The registry is also served over HTTP by a FastAPI app deployed as an AWS Lambda function, with Cognito authentication applied as a global dependency and a small set of public paths for health and docs.

| Method | Path | Description |
|---|---|---|
| `GET` | `/domains/` | List all domains |
| `GET` | `/schemas/` | List schema names (`?domain=`, `?version=`) |
| `GET` | `/schemas/{name}` | A schema document (`?version=latest`) |
| `GET` | `/schemas/{name}/versions` | List versions for a schema |
| `GET` | `/schemas/{name}/diff` | Diff two versions (`?from=&to=`) |
| `POST` | `/schemas/{name}/validate` | Validate a payload against a schema section |

The `diff` endpoint answers "what actually changed between 1.0 and 2.0", which is helpful if something starts breaking after publishing schemas. The `validate` endpoint lets a service check a payload against an `api`-type contract over HTTP, without installing the client or writing Python at all. It refuses if you point it at a `dataframe` schema, since there's no meaningful section to validate against.

Mostly, though, the API exists so that the registry is browsable by people who aren't going to `pip install` anything. Being able to send a scientist a URL that shows exactly what a table contains has done more for adoption than any amount of documentation.  I ended up building a nice dashboard that displayed datatable-specific contracts as tables, and let's users browse by domain, subdomain(s), entity, and version.  It's much easier to look at than a YAML file or Pandera class.

---

## Closing toughts

A schema registry is about making implicit contracts explicit. Before building this, the "contract" between a pipeline and its consumer (e.g. dashboards, APIs) was whatever the pipeline happened to output on any given run. Afterwards, it was a versioned, machine-readable document that both sides could validate against independently.  None of this is domain-specific, and these same patterns would work for any environment where you need versioned, queryable, code-first schema definitions that can be serialized and distributed.  I've incorporated contracts for everything from scientific instruments, to finance, to ERP domains in our registry.

I underestimated how much work the *enforcement* would be, as opposed to the contract definitions themselves. Defining schemas as Python classes is easy, and scientists who are somewhat Python-saavy can do this easily as well. Making it impossible to publish a schema that consumers can't read, or to end up with two spellings of the same type, or to quietly delete something a pipeline still depends on, took a lot longer, and is what makes the system robust.  For our small team in a domain with complex, heterogeneous data, implementing this registry and schema enforcement has been a huge boon.

---

*I work on data platform infrastructure at a biologics company. The patterns in this post are generalized from production code, with domain-specific details abstracted away. The core framework concepts are shareable.*
