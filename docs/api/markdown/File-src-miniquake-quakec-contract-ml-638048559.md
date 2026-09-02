# `src/miniquake/quakec/contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.quakec.contract`](Package-miniquake-quakec-contract-320966003.md)

Reachable from entry: **no**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/quakec/builtins.ml` as `builtins` → [src/miniquake/quakec/builtins.ml](File-src-miniquake-quakec-builtins-ml-1596628905.md)
- `miniquake/quakec/opcodes.ml` as `op` → [src/miniquake/quakec/opcodes.ml](File-src-miniquake-quakec-opcodes-ml-1466187268.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)

## Declarations

<a id="function-function-miniquake-quakec-contract-builtinreferencecount-function-builtinreferencecount-program-src-miniquake-quakec-contract-ml-1065648206"></a>
### builtinReferenceCount

```ml
function builtinReferenceCount(program)
```

Return builtin reference count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `builtinReferenceCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L142)

<a id="function-function-miniquake-quakec-contract-contractfingerprint-function-contractfingerprint-src-miniquake-quakec-contract-ml-550945750"></a>
### contractFingerprint

```ml
function contractFingerprint()
```

Implements the `contractFingerprint` operation for `miniquake.quakec.contract` (contract fingerprint).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L71)

<a id="constant-constant-miniquake-quakec-contract-expected-builtin-count-const-expected-builtin-count-79-src-miniquake-quakec-contract-ml-1952773705"></a>
### EXPECTED_BUILTIN_COUNT

```ml
const EXPECTED_BUILTIN_COUNT = 79
```

Defines the expected builtin count value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L24)

<a id="constant-constant-miniquake-quakec-contract-expected-fixme-count-const-expected-fixme-count-14-src-miniquake-quakec-contract-ml-1045172562"></a>
### EXPECTED_FIXME_COUNT

```ml
const EXPECTED_FIXME_COUNT = 14
```

Defines the expected fixme count value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L26)

<a id="constant-constant-miniquake-quakec-contract-expected-header-crc-const-expected-header-crc-5927-src-miniquake-quakec-contract-ml-1317271540"></a>
### EXPECTED_HEADER_CRC

```ml
const EXPECTED_HEADER_CRC = 5927
```

Defines the expected header crc value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L20)

<a id="constant-constant-miniquake-quakec-contract-expected-localstack-size-const-expected-localstack-size-2048-src-miniquake-quakec-contract-ml-1785759895"></a>
### EXPECTED_LOCALSTACK_SIZE

```ml
const EXPECTED_LOCALSTACK_SIZE = 2048
```

Defines the expected localstack size value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L30)

<a id="constant-constant-miniquake-quakec-contract-expected-opcode-count-const-expected-opcode-count-66-src-miniquake-quakec-contract-ml-1945179443"></a>
### EXPECTED_OPCODE_COUNT

```ml
const EXPECTED_OPCODE_COUNT = 66
```

Defines the expected opcode count value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L22)

<a id="constant-constant-miniquake-quakec-contract-expected-stack-depth-const-expected-stack-depth-32-src-miniquake-quakec-contract-ml-158678828"></a>
### EXPECTED_STACK_DEPTH

```ml
const EXPECTED_STACK_DEPTH = 32
```

Defines the expected stack depth value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L28)

<a id="constant-constant-miniquake-quakec-contract-expected-version-const-expected-version-6-src-miniquake-quakec-contract-ml-1439912683"></a>
### EXPECTED_VERSION

```ml
const EXPECTED_VERSION = 6
```

Defines the expected version value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L18)

<a id="constant-constant-miniquake-quakec-contract-fnv-offset-const-fnv-offset-2166136261-src-miniquake-quakec-contract-ml-299969249"></a>
### FNV_OFFSET

```ml
const FNV_OFFSET = 2166136261
```

Defines the fnv offset value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L32)

<a id="constant-constant-miniquake-quakec-contract-fnv-prime-const-fnv-prime-16777619-src-miniquake-quakec-contract-ml-926163337"></a>
### FNV_PRIME

```ml
const FNV_PRIME = 16777619
```

Defines the fnv prime value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L34)

<a id="function-function-miniquake-quakec-contract-hasdefinition-function-hasdefinition-definitions-name-src-miniquake-quakec-contract-ml-465127899"></a>
### hasDefinition

```ml
function hasDefinition(definitions, name)
```

Report whether definition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definitions` | `dynamic` | — | The definitions input consumed by `hasDefinition`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L123)

<a id="function-function-miniquake-quakec-contract-hasfunction-function-hasfunction-program-name-src-miniquake-quakec-contract-ml-1493045687"></a>
### hasFunction

```ml
function hasFunction(program, name)
```

Report whether function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `hasFunction`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L133)

<a id="function-function-miniquake-quakec-contract-hashbyte-inline-function-hashbyte-hash-value-src-miniquake-quakec-contract-ml-691267618"></a>
### hashByte

```ml
inline function hashByte(hash, value)
```

Returns whether `miniquake.quakec.contract` has h byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `dynamic` | — | The hash input consumed by `hashByte`. |
| `value` | `dynamic` | — | Value consumed by `hashByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L39)

<a id="function-function-miniquake-quakec-contract-hashtext-function-hashtext-hash-text-src-miniquake-quakec-contract-ml-37122137"></a>
### hashText

```ml
function hashText(hash, text)
```

Fold text into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `dynamic` | — | The hash input consumed by `hashText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L59)

<a id="function-function-miniquake-quakec-contract-hashword-function-hashword-hash-value-src-miniquake-quakec-contract-ml-1290312041"></a>
### hashWord

```ml
function hashWord(hash, value)
```

Fold word into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `dynamic` | — | The hash input consumed by `hashWord`. |
| `value` | `dynamic` | — | Value consumed by `hashWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L46)

<a id="function-function-miniquake-quakec-contract-maximumbuiltinreference-function-maximumbuiltinreference-program-src-miniquake-quakec-contract-ml-924824812"></a>
### maximumBuiltinReference

```ml
function maximumBuiltinReference(program)
```

Implements the `maximumBuiltinReference` operation for `miniquake.quakec.contract` (maximum builtin reference).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `maximumBuiltinReference`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L152)

<a id="function-function-miniquake-quakec-contract-programfingerprint-function-programfingerprint-program-src-miniquake-quakec-contract-ml-2054752260"></a>
### programFingerprint

```ml
function programFingerprint(program)
```

Implements the `programFingerprint` operation for `miniquake.quakec.contract` (program fingerprint).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `programFingerprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L199)

<a id="function-function-miniquake-quakec-contract-requiredfields-function-requiredfields-src-miniquake-quakec-contract-ml-1476991278"></a>
### requiredFields

```ml
function requiredFields()
```

Validates d fields for `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L99)

<a id="function-function-miniquake-quakec-contract-requiredfunctions-function-requiredfunctions-src-miniquake-quakec-contract-ml-1462387738"></a>
### requiredFunctions

```ml
function requiredFunctions()
```

Validates d functions for `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L113)

<a id="function-function-miniquake-quakec-contract-requiredglobals-function-requiredglobals-src-miniquake-quakec-contract-ml-351733212"></a>
### requiredGlobals

```ml
function requiredGlobals()
```

Validates d globals for `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L86)

<a id="constant-constant-miniquake-quakec-contract-status-const-status-quakec-109-frozen-v1-src-miniquake-quakec-contract-ml-786679785"></a>
### STATUS

```ml
const STATUS = "quakec_109_frozen_v1"
```

Defines the status value used by `miniquake.quakec.contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L16)

<a id="function-function-miniquake-quakec-contract-summary-function-summary-program-src-miniquake-quakec-contract-ml-1937505000"></a>
### summary

```ml
function summary(program)
```

Return summary derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `summary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L231)

<a id="function-function-miniquake-quakec-contract-validate-function-validate-program-src-miniquake-quakec-contract-ml-484002920"></a>
### validate

```ml
function validate(program)
```

Implements the `validate` operation for `miniquake.quakec.contract` (validate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `validate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/contract.ml#L165)
