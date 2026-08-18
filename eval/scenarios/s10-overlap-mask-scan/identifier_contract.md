# Identifier Contract

Variable access identifiers are opaque.

- Their body has a minimum length of 12 and no published maximum.
- The allowed body alphabet is lowercase ASCII, digits, `.`, `_`, and `-`.
- The identifier may be concatenated directly with a log key.
- The full contiguous run of allowed body characters must be masked. Under-masking
  an identifier is a correctness failure; consuming that complete run is intentional.

The redactor must honor this contract without making runtime work grow quadratically
with input length.
