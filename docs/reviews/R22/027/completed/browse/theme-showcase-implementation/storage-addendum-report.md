# Final executable storage addendum

The sealed product index `index.json` SHA256 aea9a6ffc1ed1f44f206da58f30e7e798ae020e4f0cf7796ea5c5d7416fdf216 retains the historical direct executable path. That path is now absent.
The executable was a regular single-link file, mode 0700, 19139712 bytes, SHA256 dc10aee0d5ebea4aa3a49a1fcefd97d742dcad0ae305e629a8bb177e6a5f108a; `fuser` found no active user before unlink.
Its lossless gzip witness is `evidence/final-witness/main-dc10.gz`, 5491520 bytes, SHA256 d1c13db940ac60230d90257dbacb4ad78a18feb322c7807d87d68cc194d5f3a7. Decompression was verified byte-for-byte before unlink.
`evidence/final-witness/witness-map.json` records the original path, mode, hashes, sizes, and source commits. Product source and the sealed indexes remain unchanged.
