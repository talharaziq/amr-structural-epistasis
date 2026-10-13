# AMR Structural Epistasis Analysis

Do resistance mutations that CARD lists for the same protein sit closer together in 3D than random residue pairs with the same sequence separation?

The notebook downloads the CARD database, builds pairs of resistance mutations within each protein model, fetches AlphaFold structures, measures the distance between the two residues, and compares each pair with a random control pair from the same structure.

> **Read the limitations before reusing any result.** The pairs are every combination of mutations that CARD lists for a protein. They are not shown to occur together or to depend on each other. So this project measures spatial proximity of listed resistance positions. It does not show epistasis, despite the name.

## Result

One notebook run, 112,882 mutation pairs:

| | Observed pairs | Matched controls |
|---|---|---|
| Mean Cα–Cα distance | 20.304 Å | 22.883 Å |
| Median Cα–Cα distance | 18.454 Å | 20.855 Å |

- Mean paired difference (observed − control): **−2.579 Å**, 95% CI [−2.650, −2.509]
- Median paired difference: −1.667 Å
- Paired t-test: t = −71.98. Both the t-test and the Wilcoxon signed-rank test report p = 0, which just means below floating-point precision. Do not read these p-values literally, see the limitations.
- Effect size (Cohen's dz): −0.214, small

The difference is negative in every sequence-separation bin and gets larger as separation grows:

| Residues apart | Pairs | Observed mean (Å) | Control mean (Å) | Difference (Å) |
|---|---|---|---|---|
| ≤10 | 15,045 | 10.038 | 10.770 | −0.731 |
| 11–25 | 15,819 | 18.063 | 19.760 | −1.697 |
| 26–50 | 20,261 | 17.940 | 20.080 | −2.140 |
| 51–100 | 29,291 | 20.996 | 23.358 | −2.363 |
| 101–200 | 22,767 | 22.324 | 25.274 | −2.949 |
| >200 | 9,699 | 37.990 | 45.579 | −7.589 |

Numbers come from one run. The notebook downloads the latest CARD release and current AlphaFold models, so exact values can shift a little between runs.

## Pipeline

| Step | What it does | Count after step |
|---|---|---|
| 1. Download | Gets `card.json` from card.mcmaster.ca (6,454 entries, 325 variant models) | |
| 2. Build pairs | All pairwise combinations of SNPs listed in each variant model | 121,325 |
| 3. Filter notation | Keeps plain substitutions like `A123T`. Drops non-standard notation (5,934) and pairs at the same position (1,323) | 114,068 |
| 4. Verify | Checks the wild-type residue against the CARD reference sequence. Drops mismatches (670) | 113,398 |
| 5. Map structures | CARD protein accession → UniProt (REST cross-reference search) → AlphaFold DB. 113 of 129 model combinations got a structure file | |
| 6. Distances | Cα–Cα distance for each pair. Drops pairs with no structure (516) | 112,882 |
| 7. Controls | For each pair, one random residue pair from the same structure with the same residue-number separation (seed 42) | 112,882 |
| 8. Statistics | Paired t-test, Wilcoxon signed-rank test, Cohen's dz | |
| 9. Stratify and plot | Splits by sequence separation, makes plots, writes a PyMOL script for one structure | |

## Repository layout

```
.
├── notebooks/
│   └── AMR_Structural_Epistasis_Analysis.ipynb
├── AMR_Structural_Mutation_Project/    # created by the notebook
│   ├── raw/                            # CARD download and structures (not committed)
│   ├── processed/                      # intermediate tables (not committed, except the stats JSON)
│   └── results/                        # figures and the bin table
├── requirements.txt
├── CITATION.cff
├── LICENSE
└── README.md
```

## Running it

**Colab.** Upload the notebook and run the cells in order. Colab storage is wiped when the session ends, so download `results/` and `processed/primary_statistical_results.json` before you close it.

**Locally.** Python 3.10.12 or newer.

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
jupyter notebook notebooks/AMR_Structural_Epistasis_Analysis.ipynb
```

The first cell sets `BASE_DIR = Path("/content/AMR_Structural_Mutation_Project")`, which is a Colab path. Change it to `Path("AMR_Structural_Mutation_Project")` for a local run.

You need an internet connection. The structure step makes one UniProt and one AlphaFold request per protein model and waits 0.2 s between them. The CARD archive is about 4 MB compressed and 38 MB for `card.json`.

PyMOL is optional and is not installed by pip. The last notebook step writes `render_figure3.pml`, which you can open in PyMOL to make the structure figure.

## Main outputs

| File | Contents |
|---|---|
| `processed/candidate_pairs.csv` | All pairs built from CARD |
| `processed/verified_pairs.csv` | Pairs that passed notation and wild-type checks |
| `processed/structure_mapping.csv` | CARD model → UniProt → AlphaFold file, with status per model |
| `processed/struct_distance_pairs.csv` | Observed Cα–Cα distances |
| `processed/matched_controls.csv` | One control per observed pair |
| `processed/primary_statistical_results.json` | Test statistics and effect size |
| `results/sequence_bin_stratification.csv` | The bin table above |
| `results/figures/` | Distance plots and the PyMOL script |

Excluded pairs are saved at each step with the reason, in `excluded_pairs_step*.csv`.

## Limitations

- **The pairs are not co-required.** Pairs are all combinations of SNPs listed in one CARD variant model. CARD lists these as individual resistance variants, and many are alternatives (for example several substitutions at *E. coli* folP P64). Nothing here shows two mutations occur in the same strain.
- **A few proteins dominate.** Three structures hold 94.7% of the pairs: AF-I6XD65 (PncA, 80,467 pairs, 71%), AF-P9WIE5 (15,486), and AF-P9WGY9 (RpoB, 10,974). The overall result is mostly about those proteins. The >200 bin can only come from proteins longer than 200 residues.
- **Pairs are not independent.** The same positions appear in many pairs, so the p-values are far too small. Use the effect size and the confidence interval as a rough guide only.
- **The control is easy to beat.** Controls are random residues anywhere in the protein. Resistance mutations tend to sit in functional regions such as drug-binding sites, so they would be closer than random even if they do not interact.
- **No structure quality filter.** The notebook does not filter by AlphaFold pLDDT, and it does not check that the AlphaFold sequence matches the CARD sequence. The UniProt match is the first search hit. It uses AlphaFold monomers only, and Cα distance ignores side chains.
- **Residue numbering is assumed.** CARD positions are used directly as residue numbers in the AlphaFold file.
- **Not pinned.** The notebook downloads the latest CARD release and does not record its version.

## Ideas for next steps

- Work on unique residue pairs, then per protein, then across proteins.
- Repeat without PncA, AF-P9WIE5 and RpoB.
- Use a control drawn from other resistance-associated positions in the same protein.
- Add a pLDDT filter and a sequence check between AlphaFold and CARD.
- Pin and record the CARD version.
- Use co-occurrence data from clinical isolates to find pairs that really occur together.

## Data sources

- CARD: Alcock et al. (2023), *Nucleic Acids Research* 51(D1), D690–D699. https://card.mcmaster.ca. Check CARD's license terms before reusing the data.
- AlphaFold Protein Structure Database: Jumper et al. (2021), *Nature*; Varadi et al. (2024), *Nucleic Acids Research*. https://alphafold.ebi.ac.uk
- UniProt REST API: https://rest.uniprot.org

This repository does not redistribute CARD or AlphaFold files. The notebook downloads them.

## Archive and viewer

- Zenodo archive: https://doi.org/10.5281/zenodo.23095915
- Interactive PncA structure viewer: https://talharaziq.github.io/tb-amr-structural-epistasis/figure3_interactive.html

## Citation

See `CITATION.cff`.

## License

Code is released under the MIT License (see `LICENSE`). CARD and AlphaFold data have their own terms.

## Author

Talha Raziq, Gomal Centre of Biochemistry and Biotechnology, Gomal University, Dera Ismail Khan, Pakistan. ORCID: https://orcid.org/0009-0006-2594-5715
