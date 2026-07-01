# Lookup Tables

Static lookup data, cherry-picked from ui-ux-pro-max-skill (MIT, github.com/nextlevelbuilder/ui-ux-pro-max-skill). Tables only — the reasoning engine, style prose, and raw font catalog were dropped (duplicate taste-skill / impeccable / design-bakeoff). Grep these as ground-truth when picking palette, fonts, or chart type. They seed variants; they do not replace divergence or the judges.

| File | Rows | Key columns | Use |
|---|---|---|---|
| `colors.csv` | 160 | Product Type → Primary/Secondary/Accent/Background/Card/Muted/Border/Destructive/Ring + WCAG Notes | Copy-paste token palette per product category. Verify contrast notes before use. |
| `typography.csv` | 73 | Pairing Name, Heading/Body font, Mood, Best For, CSS Import, Tailwind Config | Ready font-pair imports. Match by Mood/Best For. |
| `charts.csv` | 25 | Data Type → Best Chart Type, When (Not) To Use, A11y Grade, Library Rec | Dashboard chart selection + a11y fallback. |

## Lookup, by hand

```sh
# palette for a category
grep -i "fintech\|banking" colors.csv
# font pair by mood
grep -i "luxury\|editorial" typography.csv
# chart for a data shape
grep -i "trend\|time-series" charts.csv
```

Tables are a starting swatch, not a verdict. design-bakeoff still diverges and judges real pixels.
