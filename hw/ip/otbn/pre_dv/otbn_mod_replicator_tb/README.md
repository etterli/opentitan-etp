# OTBN modulus replicator Testbench

Testcases:
- MOD value is correctly replicated for all elements

## Test descriptions

### 001: MOD is replicated
This testcase should cover the following questions:
- MOD value is correctly replicated for all elements

Inputs:
- `mod`: a random modulus with ELEN bits
- elen = all possible values

Expected output:
- `mod_replicated`: The modulus is replicated for each element

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_mod_replicator.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<mod>, 0x<mod_rep>
```
where
- `<elen>`: one of `16, 32, 64, 128, 256`
- `<mod>`: modulus with ELEN bits aligned to the left (0x is expected)
- `<mod_rep>`: the replicated modulus vector (0x is expected)

