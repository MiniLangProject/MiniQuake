# BP-070–BP-074R5 Windows result analysis

The R5 package compiled all 76 MiniLang targets and passed BP-070, BP-071 and BP-072. BP-073 stopped in fixture 6 with:

```text
FAIL: brush mins: expected -3, got -4
```

Result archive SHA-256:

```text
7cf42d4a9a8aed1ff532d944920c8d30bed9906a8f431366e26a3b08b20d655f
```

The implementation is correct. Both `model.c` and `gl_model.c` implement `Mod_LoadSubmodels` by subtracting one from every minimum and adding one to every maximum (“spread the mins / maxs by a pixel”). The synthetic raw model bounds are `[-3,-4,0]..[2,1,12]`; the loaded bounds must therefore be `[-4,-5,-1]..[3,2,13]`.

The fixture also contained a later registry assertion expecting `-3`; R6 corrects that latent follow-up failure to `-4`. No production or native code changes are required.
